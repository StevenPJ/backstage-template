#!/bin/bash
set -eo pipefail

if ! command -v helm &> /dev/null
then
    echo "helm could not be found, installing now"
    HOMEBREW_NO_AUTO_UPDATE=1 brew install helm
fi

if ! command -v helm-docs &> /dev/null
then
    echo "helm-docs could not be found, installing now"
    if [ -z "${CI}" ]
    then
      HOMEBREW_NO_AUTO_UPDATE=1 brew install norwoodj/tap/helm-docs
    else
      GO111MODULE=on go install github.com/norwoodj/helm-docs/cmd/helm-docs@v1.11.2
    fi
fi

# shellcheck disable=SC2164
# shellcheck disable=SC1083
cd {{ cookiecutter.__chart_folder }}/{{ cookiecutter.__application_slug }}

# build dependencies and Chart.lock
helm dependency build .

# Grab the latest copy of the value.yaml of the upstream chart
helm repo add mettle https://mettle-charts.storage.googleapis.com
# shellcheck disable=SC2164
# shellcheck disable=SC1083
helm show values mettle/{{ cookiecutter.upstream_helm_chart }} > values.yaml --version "$(helm dependency list | awk '{ print $2 }'  | tail -n +2)"

# Configure the upstream chart for our app chart
# Change the image tag to a glob that CI will update
yq -e -i '.application.image.tag = "REPLACE_ME"' values.yaml
# Do not create crds by default
yq -e -i '.imageTag.createCRDs = false' values.yaml
# Update the image repository to the service name
yq -e -i '.application.image.repository = "eu.gcr.io/eevee-bank/{{ cookiecutter.__application_slug }}"' values.yaml
# Put the upstream values under the dependency name, so the values apply to the subchart
yq -e -i '{"{{ cookiecutter.upstream_helm_chart }}": .}' values.yaml

# Build docs for the app chart using README.md.gotmpl
helm-docs


cd ../../../
pwd
# shellcheck disable=SC2164
# shellcheck disable=SC1083
cp -r {{ cookiecutter.__project_name }}/{{ cookiecutter.__chart_folder }} .
# shellcheck disable=SC2164
# shellcheck disable=SC1083
cp -r {{ cookiecutter.__project_name }}/{{ cookiecutter.__github_folder }} .
# shellcheck disable=SC2164
# shellcheck disable=SC1083
rm -rf {{ cookiecutter.__project_name }}

echo "App chart created, see usage info in {{ cookiecutter.__chart_folder }}/{{ cookiecutter.__application_slug }}/README.md"