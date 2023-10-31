Root | bool | `true` |  |
| backend-generic.podSecurityContext.runAsUser | int | `1000` |  |
| backend-generic.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| backend-generic.securityContexts.application.allowPrivilegeEscalation | bool | `false` |  |
| backend-generic.securityContexts.application.capabilities.drop[0] | string | `"ALL"` |  |
| backend-generic.securityContexts.application.readOnlyRootFilesystem | bool | `true` |  |
| backend-generic.securityContexts.application.seccompProfile.type | string | `"RuntimeDefault"` |  |
| backend-generic.service.enabled | bool | `true` |  |
| backend-generic.serviceAccount.annotations | object | `{}` |  |# Service

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![AppVersion: 0.0.0](https://img.shields.io/badge/AppVersion-0.0.0-informational?style=flat-square)

A chart for Service

**Homepage:** <https://github.com/eeveebank/my-repo-name>

## Releases

This app chart is released on merges to the master branch. The pipeline will generate a new semantic version, and then promote the changes through each environment one at a time. The app chart will include the correct docker image version. This means that chart changes can now go through the pipelines, reducing the risks of untested changes reaching production. Environment specific configuration can still be defined directly in the ArgoApplication resources. With app charts, this env config should be minimal, and will still allow env specific changes to go without needing to run the whole pipeline i.e. toggling resources/feature flags. Renovate will automatically suggest updates to the upstream charts for you.

## Deploying the Chart

You should add an ArgoApplication to k8s-releases-mettle that deploys your app chart. For an example, see the [ssv-debit-card-migration](https://github.com/eeveebank/k8s-releases-mettle/blob/master/kustomize/dev/ssv/applications/ssv-debit-card-migration.yaml) service. Note the following:
```yaml
spec:
  project: zz-unknown-ownership-apps
  source:
    repoURL: ghcr.io/eeveebank/ssv-debit-card # the helm chart is published to github container registry
    chart: ssv-debit-card-migration # the name of the chart
    targetRevision: 0.0.856 # the semantic version of the chart, this is what github actions will promote during deployments
```

There is a helm diff action in `.github/workflows/helm-diff.yaml` which will generate a diff of the rendered helm chart on PR's whenever the chart changes. This is helpful as you can see what specific resources change when a value is updated. There is an example of how to deploy the chart using GHA in `.github/workflows/deploy-app-chart.yml`. You can copy the steps into an existing workflow, or tweak the workflow for your specific use case. The `uses: eeveebank/github-actions-backend/.github/workflows/run-release-app-chart.yaml@master` job will package the app chart, publish it to ghcr with the correct docker version of the app. The `uses: eeveebank/github-action-deploy/.github/workflows/deploy-argo-app.yaml@master` job will update the argo application in k8s-releases-mettle.

## Making chart changes

Each component depends on an upstream chart in Chart.yaml. You should put any configuration common in each environment in `values.yaml` i.e. the config that lived in `k8s-releases-mettle/kustomize/base`. If you want to override any component configuration from the parent chart, then you can update the `values.yaml` as described in the [helm subchart docs](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/), i.e.

in `values.yaml`
```yaml
upstream-chart-name: # this key is defined in the chart dependencies in Chart.yaml
  application:
    replicaCount: 1
```

You can also add additional resources to the app chart in the `templates/` directory. For example to package kafka topics with the app chart, you can create a `templates/topic.yaml` file which renders the topic, which can take advantage of [helm templates](https://helm.sh/docs/chart_best_practices/templates/). The following example dynamically changes partitions based on the `env` property defined in the `values.yaml`. This can simplify your environment configuration i.e only define an `env` value and let the helm chart render the right config for you.
```yaml
apiVersion: kafka.mettle.co.uk/v1
kind: Topic
metadata:
  labels:
    controller-tools.k8s.io: "1.0"
  name: ssv-form3-payment-events-v7
  namespace: ssv
  annotations:
    spec.kafka.mettle.co.uk/override: "true" # to allow acl setup
spec:
  {{ if $.Values.env == prd -}}
    numPartitions: 12
  {{ else -}}
    numPartitions: 3
  {{- end -}}

  replicationFactor: 3
  immutable: true
  config:
    min.insync.replicas: "2"
    retention.ms: "-1"
```
## Updating the documentation

We use [`helm-docs`](https://github.com/norwoodj/helm-docs/tree/master#installation) to generate this README + Values from the `README.md.gotmpl`. Please install and use `helm-docs` any time the `values.yaml` file is changed.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://mettle-charts.storage.googleapis.com | backend-generic | 4.12.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend-generic.application.args | list | `[]` |  |
| backend-generic.application.autoscaling.behaviour | string | `"off"` |  |
| backend-generic.application.autoscaling.horizontal.maxReplicas | int | `5` |  |
| backend-generic.application.autoscaling.horizontal.minReplicas | int | `2` |  |
| backend-generic.application.autoscaling.horizontal.targetCPUUtilizationPercentage | int | `80` |  |
| backend-generic.application.autoscaling.horizontal.targetMemoryUtilizationPercentage | int | `80` |  |
| backend-generic.application.autoscaling.vertical.controlledResources[0] | string | `"cpu"` |  |
| backend-generic.application.autoscaling.vertical.controlledResources[1] | string | `"memory"` |  |
| backend-generic.application.autoscaling.vertical.controlledValues | string | `"RequestsAndLimits"` |  |
| backend-generic.application.autoscaling.vertical.maxAllowed.cpu | int | `2` |  |
| backend-generic.application.autoscaling.vertical.maxAllowed.memory | string | `"2Gi"` |  |
| backend-generic.application.autoscaling.vertical.minAllowed.cpu | string | `"100m"` |  |
| backend-generic.application.autoscaling.vertical.minAllowed.memory | string | `"128Mi"` |  |
| backend-generic.application.configMaps | object | `{}` |  |
| backend-generic.application.container.httpsEnabled | bool | `false` |  |
| backend-generic.application.container.httpsPort | int | `8443` |  |
| backend-generic.application.container.port | int | `8080` |  |
| backend-generic.application.datadog.logs.enabled | bool | `false` |  |
| backend-generic.application.datadog.logs.log_processing_rules | list | `[]` |  |
| backend-generic.application.datadog.logs.source | string | `"java"` |  |
| backend-generic.application.datadog.openmetrics.enabled | bool | `false` |  |
| backend-generic.application.datadog.openmetrics.metrics | list | `[]` |  |
| backend-generic.application.datadog.openmetrics.namespace | string | `nil` |  |
| backend-generic.application.env | object | `{}` |  |
| backend-generic.application.envFromConfigMap | list | `[]` |  |
| backend-generic.application.envFromSecret | list | `[]` |  |
| backend-generic.application.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend-generic.application.image.repository | string | `"eu.gcr.io/eevee-bank/service"` |  |
| backend-generic.application.image.tag | string | `"REPLACE_ME"` |  |
| backend-generic.application.imagePullSecretName | string | `""` |  |
| backend-generic.application.ingress.additionalPaths | list | `[]` |  |
| backend-generic.application.ingress.enabled | bool | `false` |  |
| backend-generic.application.ingress.host | string | `"example.eevee.sbx-mettle.co.uk"` |  |
| backend-generic.application.ingress.ingressClassName | string | `"nginx"` |  |
| backend-generic.application.ingress.tls.enabled | bool | `true` |  |
| backend-generic.application.ingress.tls.secret | object | `{}` |  |
| backend-generic.application.lifecycle.preStop.exec.command[0] | string | `"sleep"` |  |
| backend-generic.application.lifecycle.preStop.exec.command[1] | string | `"10"` |  |
| backend-generic.application.livenessProbe.failureThreshold | int | `24` |  |
| backend-generic.application.livenessProbe.httpGet.path | string | `"/health"` |  |
| backend-generic.application.livenessProbe.httpGet.port | int | `8080` |  |
| backend-generic.application.livenessProbe.initialDelaySeconds | int | `60` |  |
| backend-generic.application.livenessProbe.timeoutSeconds | int | `30` |  |
| backend-generic.application.minReadySeconds | int | `90` |  |
| backend-generic.application.nodeSelector | object | `{}` |  |
| backend-generic.application.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| backend-generic.application.podAnnotations."prometheus.io/port" | string | `"8080"` |  |
| backend-generic.application.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| backend-generic.application.readinessProbe.failureThreshold | int | `24` |  |
| backend-generic.application.readinessProbe.httpGet.path | string | `"/health"` |  |
| backend-generic.application.readinessProbe.httpGet.port | int | `8080` |  |
| backend-generic.application.readinessProbe.initialDelaySeconds | int | `60` |  |
| backend-generic.application.readinessProbe.timeoutSeconds | int | `30` |  |
| backend-generic.application.replicaCount | int | `3` |  |
| backend-generic.application.resources.limits.memory | string | `"512Mi"` |  |
| backend-generic.application.resources.requests.cpu | string | `"200m"` |  |
| backend-generic.application.resources.requests.memory | string | `"128Mi"` |  |
| backend-generic.application.service.annotations | object | `{}` |  |
| backend-generic.application.serviceAccount.create | bool | `true` |  |
| backend-generic.application.serviceAccount.name | string | `""` |  |
| backend-generic.application.sidecarContainers | list | `[]` |  |
| backend-generic.application.tolerations | list | `[]` |  |
| backend-generic.application.volumes.configMapVolumeMounts | list | `[]` |  |
| backend-generic.application.volumes.configMapVolumes | list | `[]` |  |
| backend-generic.application.volumes.emptyDirVolumeMounts | list | `[]` |  |
| backend-generic.application.volumes.emptyDirVolumes | list | `[]` |  |
| backend-generic.application.volumes.enabled | bool | `false` |  |
| backend-generic.application.volumes.secretVolumeMounts | list | `[]` |  |
| backend-generic.application.volumes.secretVolumes | list | `[]` |  |
| backend-generic.aws.iam.enabled | bool | `false` |  |
| backend-generic.aws.iam.method | string | `"kiam"` |  |
| backend-generic.aws.iam.role | string | `nil` |  |
| backend-generic.backstage.language | string | `nil` |  |
| backend-generic.backstage.system | string | `nil` |  |
| backend-generic.backstage.tier | string | `nil` |  |
| backend-generic.chaos.enabled | bool | `false` |  |
| backend-generic.chaos.killMode | string | `"fixed"` |  |
| backend-generic.chaos.killValue | int | `1` |  |
| backend-generic.chaos.mtbf | int | `1` |  |
| backend-generic.dependsOn.additionalApplications | list | `[]` |  |
| backend-generic.imageTag.createCRDs | bool | `false` |  |
| backend-generic.imageTag.env | string | `"prd"` |  |
| backend-generic.maintainedBy | string | `"mettle"` |  |
| backend-generic.perimener.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend-generic.perimener.image.repository | string | `"eu.gcr.io/mettle-bank/perimener"` |  |
| backend-generic.perimener.image.tag | string | `"1.1.265"` |  |
| backend-generic.podLabels | object | `{}` |  |
| backend-generic.podSecurityContext.fsGroup | int | `1000` |  |
| backend-generic.podSecurityContext.runAsGroup | int | `1000` |  |
| backend-generic.podSecurityContext.runAsNon