{{/*
Define the standardized name of this helm chart and its objects
*/}}
{{- define "name" -}}
{{- required "A valid Values.name is required!" .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the standardized namespace, this is NOT defined in the output yaml files,
but it is used inside some variables and eg: for the urls generated for our
ingresses (namespaced subdomain urls, etc)
*/}}
{{- define "namespace" -}}
{{- required "A valid global.namespace is required!" .Values.global.namespace -}}
{{- end -}}

{{/*
A helper to print env variables TODO MAKE THIS WORKS
Exmaple: {{- include "print_envs" .Values.globalEnvs | indent 12 }}
*/}}
{{- define "print_envs" -}}
{{- range . }}
- name: {{ .name | quote }}
  {{- if .value }}
  value: {{ with .value }}{{ tpl . $ | quote }}{{- end }}
  {{- end }}
  {{- if .valueFrom }}
  valueFrom:
{{ .valueFrom | toYaml | indent 16 }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate basic labels for pods/services/etc
Sample Usage: {{- include "labels" . | indent 2 }}
*/}}
{{- define "labels" }}
labels:
{{- if .Values.labelsEnableDefault }}
  app: {{ .Values.name | trunc 63 | trimSuffix "-" | quote }}
{{- end }}
  chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
  release: {{ .Release.Name | quote }}
  heritage: {{ .Release.Service | quote }}
  helm_chart_author: "DevOps-Nirvana"
  generator: "helm"
{{ if .Values.labels -}}
{{ toYaml .Values.labels | indent 2 }}
{{- end }}

{{- end }}


{{/*
Get our repo based on our environment name, but allow overriding if someone thinks they know better
*/}}
{{- define "get-repository" -}}
{{- required "A valid Values.image.repository is required!" .Values.image.repository | trimSuffix ":" -}}
{{- end -}}


{{/*
Get our release tag the best we can.
If we are customizing the image repository then this is not built internally, use image.tag or latest
If we are not, then use global image tag if set (from gitlab ci/cd) or fallback to image tag
*/}}
{{- define "get-release-tag" -}}

{{- if .Values.image.repository -}}

{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else if .Values.global.image.tag -}}
{{- .Values.global.image.tag -}}
{{- else -}}
latest
{{- end -}}

{{- else -}}

{{- if .Values.global.image.tag -}}
{{- .Values.global.image.tag -}}
{{- else if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
no-image-tag-could-be-found
{{- end -}}

{{- end -}}

{{- end -}}


{{/*
Create the name of the ingress resource (used for legacy purposes and zero downtime for legacy)
*/}}
{{- define "ingress.name" -}}
{{- if .Values.ingress.name -}}
    {{ .Values.ingress.name }}
{{- else -}}
    {{ template "name" . }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the ingress_secondary resource (used for legacy purposes and zero downtime for legacy)
*/}}
{{- define "ingress_secondary.name" -}}
{{- if .Values.ingress_secondary.name -}}
    {{ .Values.ingress_secondary.name }}
{{- else -}}
    {{ template "name" . }}
{{- end -}}
{{- end -}}