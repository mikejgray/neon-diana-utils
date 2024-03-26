{{- define "base-http.deployment" -}}
{{- $fullName := default .Chart.Name  .Values.serviceName -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $fullName }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      neon.diana.service: {{ $fullName }}
  strategy:
    type: Recreate
  template:
    metadata:
      annotations:
        releaseTime: {{ dateInZone "2006-01-02 15:04:05Z" (now) "UTC"| quote }}
      labels:
        neon.diana.service: {{ $fullName }}
        neon.project.name: diana
        neon.service.class: http-backend
    spec:
      containers:
        - image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          name: {{ $fullName }}
          ports:
            - name: {{ $fullName }}
              containerPort: {{ .Values.servicePort }}
              protocol: TCP
          {{- if .Values.configSecret || .Values.volumeMounts }}
          volumeMounts:
          {{- if .Values.configSecret }}
            - mountPath: /config/neon
              name: config
          {{- if .Values.volumeMounts }}
          {{- toYaml $.Values.volumeMounts | nindent 12 -}}
          {{- if .Values.resources }}
          resources:
          {{- toYaml $.Values.resources | nindent 12 -}}
          {{ end }}
      volumes:
        - name: config
          projected:
            sources:
              - secret:
                  name: {{ .Values.configSecret }}
        {{- if .Values.volumes}}
        {{- toYaml $.Values.volumes | nindent 8 -}}
        {{- end }}
      {{- end }}
      restartPolicy: Always
{{- end -}}