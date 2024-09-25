---


{{- define "zenoh-session-volume-mount" }}
            - name: zenoh-cfg
              mountPath: /zenoh-sessions.config.json
              subPath: zenoh-sessions.config.json
{{- end}}


{{- define "zenoh-bridge" }}
        - name: zenoh-bridge-pod
          image:  eclipse/zenoh-bridge-dds:latest
          args: [
            "-m client",
            "--fwd-discovery",
            "-e {{ .Values.services.zenoh.proto | lower }}/{{ .Values.services.zenoh.name }}:{{ .Values.services.zenoh.port }}",
            "-l {{ .Values.services.zenoh.proto | lower }}/0.0.0.0:{{ .Values.services.zenoh.port }}",
          ]
          env:
          - name: ROS_DISTRO
            value: {{ .Values.ros.distro }}
          - name: RUST_LOG
            value: "DEBUG"
          envFrom:
            {{- include "ros-common-env" . }}
          volumeMounts:
            {{- include "zenoh-session-volume-mount" . }}
{{- end}}


{{- define "zenoh-env" }}
{{- if eq .Values.containers.zenoh_logging true }}
          env:
            - name: RUST_LOG
              value: "DEBUG"
{{- end}}
{{- end}}

{{- define "local-affinity" }}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: liqo.io/type
                    operator: NotIn
                    values:
                      - virtual-node
{{- end}}
{{- define "remote-affinity" }}
{{- if eq .Values.containers.environment.offload true }}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: liqo.io/type
                    operator: In
                    values:
                      - virtual-node
{{- end}}
{{- if eq .Values.containers.environment.offload false }}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: liqo.io/type
                    operator: NotIn
                    values:
                      - virtual-node
{{- end}}
{{- end}}

{{- define "ros-probes" }}
{{- if eq .Values.containers.environment.disable_healthcheck false }}
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
{{- end }}

{{- define "zenoh-session-volumes" }}
        - name: zenoh-cfg
          configMap:
            name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-config
            items:
              - key: zenoh-sessions.config.json
                path: zenoh-sessions.config.json
{{- end}}



{{- define "simulation-image" }}
          image: {{ .Values.ros.images.simulation.registry }}/{{ .Values.ros.images.simulation.project }}/{{ .Values.ros.images.simulation.repository }}:{{ .Values.ros.images.simulation.flavor }}-{{ .Values.ros.distro }}-{{ .Values.ros.images.simulation.version }}
          imagePullPolicy: Always
{{- end}}
{{- define "zenoh-image" }}
          image: {{ .Values.ros.images.zenoh.registry }}/{{ .Values.ros.images.zenoh.project }}/{{ .Values.ros.images.zenoh.repository }}:{{ .Values.ros.distro }}-{{ .Values.ros.images.zenoh.version }}
          imagePullPolicy: Always
{{- end}}

{{- define "ros-common-env" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-ros-env
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-session-env
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
