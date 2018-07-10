prometheus_docker_container:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - source: salt://prometheus/prometheus.yml
  docker_container.running:
    - name: prometheus
    - image: {{salt['environ.get']('DOCKER_LOCAL_REGISTRY')}}/prometheus:{{salt['environ.get']('PROMETHEUS_VERSION')}}
    - port_bindings: 9090:9090
    - binds: /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro 
    - restart_policy: always
    - watch:
      - file: /etc/prometheus/prometheus.yml

