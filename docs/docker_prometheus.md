Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
Prometheus | Time-series database          | <https://prometheus.io>

# Prometheus

Deploy a [Promethes server][24] and a Prometheus [Node exporter][25] in dedicated containers:

File                                                        | Description
------------------------------------------------------------|-----------------------------------------
[srv/salt/prometheus/prometheus.yml][28]                    | Prometheus server configuration file
[var/aliases/prometheus.sh][22]                             | Shell functions for Prometheus
[srv/salt/prometheus/prometheus-docker-container.sls][23]   | Salt state to configure the Prometheus docker container
[.../prometheus-node-exporter-docker-container.sls][27]     | Salt state configuration for the node exporter

```bash
# exec masterless Salt to run a Prometheus and Node exporterdocker container
vm ex $SALT_MASTER -r '
        salt-local prometheus/prometheus-docker-container
        salt-local prometheus/prometheus-node-exporter-docker-container
'
# access Prometheus WUI from the VM host
$BROWSER http://$(vm ip lxcm01):9090/targets
```

The Prometheus docker container is created by the following Salt configuration (cf. [prometheus-docker-container.sls][23]):

```sls
prometheus_docker_container:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - makedirs: True
    - source: salt://prometheus/prometheus.yml
  docker_container.running:
    - name: prometheus
    - image: {{salt['environ.get']('DOCKER_LOCAL_REGISTRY')}}/prometheus:{{salt['environ.get']('PROMETHEUS_VERSION')}}
    - port_bindings: 9090:9090
    - binds: /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    - restart_policy: always
    - watch:
      - file: /etc/prometheus/prometheus.yml
```

Salt configuration for the Node exporter (cf. [prometheus-node-exporter-docker-container.sls][27]):

```sls
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
    - binds:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
```

Alternatively login to the VM and run the containers using the Docker CLI:

```bash
# start the Prometheus container from the private registry
docker run --interactive \
           --tty --rm \
           --name prometheus \
           --publish 9090:9090 \
           --volume $SALT_STATE_TREE/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
           $DOCKER_LOCAL_REGISTRY/prometheus:$PROMETHEUS_VERSION
# start the Prometheus node-exporter...
docker run --interactive \
           --tty --rm \
           --name prometheus-node-exporter \
           --publish 9100:9100 \
           --volume "/proc:/host/proc" \
           --volume "/sys:/host/sys" \
           --volume "/:/rootfs" \
           $DOCKER_LOCAL_REGISTRY/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION \
                            --path.procfs /host/proc \
                            --path.sysfs /host/sys \
                            --collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
```

Both commands are wrapped with the shell functions:

- [prometheus-docker-container()][22] - Run Prometheus service container
- [prometheus-node-exporter-docker-container()][22] - Run Prometheus service container

Cf. [Collect Docker metrics with Prometheus][26]


[22]: ../var/aliases/prometheus.sh
[23]: ../srv/salt/prometheus/prometheus-docker-container.sls
[24]: https://github.com/prometheus/prometheus
[25]: https://github.com/prometheus/node_exporter
[26]: https://docs.docker.com/config/thirdparty/prometheus/
[27]: ../srv/salt/prometheus/prometheus-node-exporter-docker-container.sls
[28]: ../srv/salt/prometheus/prometheus.yml
