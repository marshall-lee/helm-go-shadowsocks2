{{/*
Expand the name of the chart.
*/}}
{{- define "go-shadowsocks2.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "go-shadowsocks2.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "go-shadowsocks2.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "go-shadowsocks2.labels" -}}
helm.sh/chart: {{ include "go-shadowsocks2.chart" . }}
{{ include "go-shadowsocks2.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "go-shadowsocks2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "go-shadowsocks2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "go-shadowsocks2.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "go-shadowsocks2.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
v2ray plugin options string
*/}}
{{- define "go-shadowsocks2.v2rayOpts" -}}
{{- $opts := list }}
{{- if .server }}
{{- $opts = mustAppend $opts "server" }}
{{- end }}
{{- $opts = mustAppend $opts (printf "mode=%s" (required "v2ray mode is required" .mode)) }}
{{- if .tls.enabled }}
{{- if .server  }}
{{- if (not .ingress.enabled) }}
{{- $opts = mustAppend $opts "tls" }}
{{- $opts = mustAppend $opts (printf "host=%s" (required "v2ray host is required" .host)) }}
{{- $opts = mustAppend $opts "cert=/etc/tls/tls.crt" }}
{{- $opts = mustAppend $opts "key=/etc/tls/tls.key" }}
{{- end }}
{{- else }}
{{- $opts = mustAppend $opts "tls" }}
{{- $opts = mustAppend $opts (printf "host=%s" (required "v2ray host is required" .host)) }}
{{- end }}
{{- end }}
{{- $opts = mustAppend $opts (printf "loglevel=%s" .loglevel) }}
{{- join ";" $opts }}
{{- end }}

{{/*
v2ray tls secret name
*/}}
{{- define "go-shadowsocks2.v2raySecretName" -}}
{{- default (printf "%s-v2ray-tls" (include "go-shadowsocks2.fullname" .)) .v2ray.tls.secretName }}
{{- end }}