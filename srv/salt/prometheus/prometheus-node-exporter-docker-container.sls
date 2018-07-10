prometheus_node_exporter_docker_container:
  docker_container.running:
    - name: prometheus-node-exporter
    - image: {{salt['environ.get']('DOCKER_LOCAL_REGISTRY')}}/prometheus-node-exporter:{{salt['environ.get']('PROMETHEUS_NODE_EXPORTER_VERSION')}}
    - cmd: 
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)'
    - port_bindings: 9100:9100
    - restart_policy: always
    - volumes:
      - /proc:/host/proc
      - /sys:/host/sys
      - /:/rootfs

