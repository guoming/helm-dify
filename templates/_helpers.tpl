{{/*
Expand the name of the chart.
*/}}
{{- define "dify.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dify.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified api name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.api.fullname" -}}
{{ template "dify.fullname" . }}-api
{{- end -}}

{{/*
Create a default fully qualified worker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.worker.fullname" -}}
{{ template "dify.fullname" . }}-worker
{{- end -}}

{{/*
Create a default fully qualified web name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.web.fullname" -}}
{{ template "dify.fullname" . }}-web
{{- end -}}

{{/*
Create a default fully qualified web name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.sandbox.fullname" -}}
{{ template "dify.fullname" . }}-sandbox
{{- end -}}

{{/*
Create a default fully qualified web name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.ssrfProxy.fullname" -}}
{{ template "dify.fullname" . }}-ssrf-proxy
{{- end -}}

{{/*
Create a default fully qualified nginx name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.nginx.fullname" -}}
{{ template "dify.fullname" . }}-proxy
{{- end -}}

{{/*
Create a default fully qualified plugin-daemon name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.pluginDaemon.fullname" -}}
{{ template "dify.fullname" . }}-plugin-daemon
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dify.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dify.labels" -}}
helm.sh/chart: {{ include "dify.chart" . }}
{{ include "dify.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* labels defiend by user*/}}
{{- define "dify.ud.labels" -}}
{{- if .Values.labels }}
{{- toYaml .Values.labels }}
{{- end -}}
{{- end -}}

{{/* annotations defiend by user*/}}
{{- define "dify.ud.annotations" -}}
{{- if .Values.annotations }}
{{- toYaml .Values.annotations }}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "dify.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dify.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dify.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dify.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dify.namespace" -}}
{{- if .Values.namespace -}}
    {{ .Values.namespace }}
{{- else -}}
    {{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
HPA ApiVersion according k8s version
Check legacy first so helm template / kustomize will default to latest version
*/}}
{{- define "dify.hpa.apiVersion" -}}
{{- if and (.Capabilities.APIVersions.Has "autoscaling/v2beta2") (semverCompare "<1.23-0" .Capabilities.KubeVersion.GitVersion) -}}
autoscaling/v2beta2
{{- else -}}
autoscaling/v2
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the Dify Plugin Daemon
*/}}
{{- define "dify.pluginDaemon.serviceAccountName" -}}
{{- if .Values.pluginDaemon.serviceAccount.create -}}
    {{ default (include "dify.pluginDaemon.fullname" .) .Values.pluginDaemon.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.pluginDaemon.serviceAccount.name }}
{{- end -}}
{{- end -}}



{{/*
Create a default fully qualified gateway name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.gateway.fullname" -}}
{{ template "dify.fullname" . }}-gateway
{{- end -}}

{{/*
Create a default fully qualified virtualService name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.virtualService.fullname" -}}
{{ template "dify.fullname" . }}-vs
{{- end -}}


{{/*
Create a default fully qualified destinationRule name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dify.destinationRule.fullname" -}}
{{ template "dify.fullname" . }}-dr
{{- end -}}