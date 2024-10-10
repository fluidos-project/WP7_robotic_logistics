---
{{- define "ros-probes" }}
          startupProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end }}

{{- define "zenoh-session-volumes" }}
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp"}}
        - name: zenoh-cfg
          configMap:
            name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-config
            items:
              - key: zenoh-sessions.config.json
                path: zenoh-sessions.config.json
{{- end}}
{{- end}}

{{- define "zenoh-session-volume-mount" }}
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
            - name: zenoh-cfg
              mountPath: /home/robot/config/zenoh-sessions.config.json
              subPath: zenoh-sessions.config.json
{{- end}}
{{- end}}

{{- define "simulation-image" }}
          image: {{ .Values.ros.images.simulation.registry }}/{{ .Values.ros.images.simulation.project }}/{{ .Values.ros.images.simulation.repository }}:{{ .Values.ros.images.simulation.flavor }}-{{ .Values.ros.distro }}-{{ .Values.ros.images.simulation.version }}
          imagePullPolicy: Always
{{- end}}
{{- define "zenoh-image" }}
          image: {{ .Values.ros.images.zenoh.registry }}/{{ .Values.ros.images.zenoh.project }}/{{ .Values.ros.images.zenoh.repository }}:{{ .Values.ros.distro }}-{{ .Values.ros.images.zenoh.version }}
          imagePullPolicy: Always
{{- end}}
{{- define "web-volumes" }}
        - name: nginx-cfg
          emptyDir: {}
        - name: web
          emptyDir: {}
        - name: data
          emptyDir: {}
{{- end}}
{{- define "novnc-container" }}
        - name: web-loader
          imagePullPolicy: Always
          image: robotnik/novnc:web-1.3.0-2-rc02
          volumeMounts:
            - name: web
              mountPath: /web
            - name: nginx-cfg
              mountPath: /config
          command:
            - /bin/sh
            - '-c'
          args:
            - |
              if ! cp -r /data/web/* /web
              then
                echo "error loading web"
                exit 1
              fi
              if ! cp -r /data/config/* /config
              then
                echo "error loading nginx-config"
                exit 1
              fi
              echo "done"
{{- end}}
{{- define "websockify-container" }}
        - name: websocket
          image: robotnik/websockify:backend-0.11.0-1
          imagePullPolicy: Always
          env:
            - name: USE_ENV_CONFIG
              value: "true"
            - name: VERBOSE
              value: "true"
            - name: VNC_HOST
              value: "localhost"
            - name: VNC_PORT
              value: "5900"
            - name: WS_PORT
              value: "8080"
          ports:
            - containerPort: 8080
              name: websocket
          startupProbe:
            tcpSocket:
              port: websocket
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            tcpSocket:
              port: websocket
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            tcpSocket:
              port: websocket
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end}}
{{- define "webserver-container" }}
        - name: webserver
          image: nginx:1.27.0-alpine3.19
          volumeMounts:
            - name: web
              mountPath: /var/www/html/web
            - name: nginx-cfg
              mountPath: /etc/nginx/templates/
          imagePullPolicy: Always
          env:
            - name: WEBSITE_PATH
              value: "/var/www/html/web"
            - name: PHP_SERVER
              value: "localhost"
            - name: PHP_PORT
              value: "9000"
            - name: NGINX_SERVER
              value: "localhost"
            - name: NGINX_PORT
              value: "80"
          ports:
            - containerPort: 80
              name: http
          startupProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end}}
{{- define "php-container" }}
        - name: php
          image: php:8.0.30-fpm-alpine3.16
          imagePullPolicy: Always
          volumeMounts:
            - name: web
              mountPath: /var/www/html/web
          ports:
            - containerPort: 9000
              name: php
          startupProbe:
            tcpSocket:
              port: php
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            tcpSocket:
              port: php
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            tcpSocket:
              port: php
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end}}
{{- define "filebrowser-container" }}
        - name: fileserver
          image: robotnik/filebrowser:2.24.2-1
          volumeMounts:
            - name: data
              mountPath: /srv
          imagePullPolicy: Always
          env:
            - name: WEB_PORT
              value: "81"
          command:
            - /filebrowser
          args:
            - --config=/.filebrowser.json
            - --port
            - "81"
          ports:
            - containerPort: 81
              name: http
          startupProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end}}

{{- define "ros-common-env" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-ros-env
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-session-env
{{- end}}
{{- end}}

{{- define "robot-1-env" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-robot-1-id-env
{{- end}}


{{- define "lifecycle" }}

{{- if eq .Values.containers.environment.production true }}
          lifecycle:
            postStart:
              exec:
                command:
                  - "/bin/bash"
                  - "-c"
                  - |
                    sudo chmod -x \
                      /usr/bin/aria2c \
                      /usr/bin/wget \
                      /usr/bin/curl \
                      /usr/bin/curl-config \
                      /usr/bin/sftp
                    if [[ -e /etc/sudoers.d/robot ]]; then
                      sudo rm /etc/sudoers.d/robot || exit 1
                    else
                      sudo sed -i '/%robot ALL=(ALL) NOPASSWD:ALL/d' /etc/sudoers || exit 1
                    fi
                    exit 0
{{- end}}
{{- end}}

{{- define "robot-1-dep" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: robot-1-{{ . }}
  labels:
    app: robot-1-{{ . }}
    group: robot-1
    robotType: simulated
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: robot-1-{{ . }}
      group: robot-1
      robotType: simulated
  template:
    metadata:
      labels:
        app: robot-1-{{ . }}
        group: robot-1
        robotType: simulated
    spec:
      restartPolicy: Always
      {{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
      volumes:
       {{- include "zenoh-session-volumes" . }}
       {{- end }}
      containers:
        - name: world
          {{- include "simulation-image" .}}
          {{- include "lifecycle" .}}
          {{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
          volumeMounts:
            {{- include "zenoh-session-volume-mount" . }}
          {{- end }}
          {{- include "ros-probes" . }}
          envFrom:
            {{- include "ros-common-env" . }}
            {{- include "robot-1-env" . }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-world-env
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-launcher-{{ . }}-env
{{- end}}