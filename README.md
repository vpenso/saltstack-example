# SaltStack with Docker

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>
Prometheus | Time-series database          | <https://prometheus.io>

Bootstrap the VM to run a **Salt master as a service in a Docker container**:

File                                    | Description
----------------------------------------|-----------------------------------------
[bin/salt-master-vm-instance][31]       | Boot a VM with a Salt master docker container

Execute `salt-master-vm-instance`, cf. [INSTALL.md](INSTALL.md)

# Docker Registry

Deploy a [Docker registry server][14] container:

File                                       | Description
-------------------------------------------|-----------------------------------------
[srv/salt/docker/registry-docker-container.sls][15] | Salt state file to pull & run a Docker registry container
[srv/salt/docker/docker-daemon-insecure.sls][20]    | Salt state to configure Docker daemon
[srv/salt/docker/docker-daemon-insecure.json][21]   | Docker daemon configuration file


Execute **masterless Salt to pull and run a private docker registry**. Configure the docker daemon on pull from [an insecure registry][17]:

* [prometheus-dockerhub-images-to-local-registry][22] - Copy the Prometheus and Node Exporter **container images from DockerHub to the local registry**
* [docker-list-local-repository-catalog][11] - List container repositories on the local registry
* [docker-list-local-repository-tags()][11] -  List tags for a given container repository on the local registry

```bash
vm ex lxcm01 -r '
        # exec masterless Salt to pull and run the Docker private registry container
        salt-call-local-state docker/registry-docker-container
        # allow docker daemon insecure acccess to the local registry
        salt-call-local-state docker/docker-daemon-insecure
        # pull, tag, and push prometheus and node-exporter container images
        prometheus-dockerhub-images-to-local-registry
        # list repos in local registry
        docker-list-local-repository-catalog
'
```

Alternatively login to the VM and configure the components manually:

```bash
# write the Docker daemon configuration
echo -e "{\n \"insecure-registries\" : [\"lxcm01:5000\"]\n}" > /etc/docker/daemon.json
# restart the Docker daemon for the configuration to take effect
systemctl restart docker
# start the Docker registry container
docker run -d -p 5000:5000 --restart=always --name docker-registry registry:2.6.2
# pull the Prometheus node-exporter from DockerHub
docker pull prom/node-exporter:v0.16.0
# push it to the private registry
docker tag prom/node-exporter:v0.16.0 localhost:5000/prometheus-node-exporter:v0.16.0
docker push localhost:5000/prometheus-node-exporter:v0.16.0
# do the same for the prom/prometheus container image
# list all content of the local repository
curl -s -X GET http://localhost:5000/v2/_catalog | jq '.'
```

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
vm ex lxcm01 -r '
        salt-call-local-state prometheus/prometheus-docker-container
        salt-call-local-state prometheus/prometheus-node-exporter-docker-container
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

# Docker Swarm

Deploy a [Docker Swarm Cluster][29] using following VMs: 

Node           | Description
---------------|------------------------------------
lxcm01         | docker, docker-registry, salt-master, prometheus
lxb00[1-3]     | docker (swarm nodes)

Start additional VMs and bootstrap Salt:

```bash
export NODES=lxb00[1-3]
# start additional nodes part or the Docker swarm cluster
vn s centos7
# add the SaltStack package repository
vn sy -r $SALT_DOCKER_PATH/etc/yum.repos.d/salt.repo  :/etc/yum.repos.d/
# install the SaltStack minions
vn ex -r "
        # disable the firewall
        systemctl disable --now firewalld
        yum install -y salt-minion
        # connte to the salt-master
        echo master: $(vm ip lxcm01) > /etc/salt/minion
        systemctl enable --now salt-minion && systemctl status salt-minion
"
```

Configure the nodes using the salt-master:

```bash
vm ex lxcm01 -r '
        # accept all Salt minions
        docker exec salt-master salt-key -A -y
        # install Docker CE on all nodes
        docker exec salt-master salt -t 300 -E lxb state.apply docker/docker-ce
`
```

Cf. [Run Docker Engine in swarm mode][30]:

```bash
# create a Docker swarm manager
vm ex lxcm01 -r -- docker swarm init --advertise-addr $(vm ip lxcm01)
# export the join token to an environment variable
export DOCKER_SWARM_WORKER_TOKEN=$(vm ex lxcm01 -r -- docker swarm join-token --quiet worker)
# add nodes to the swarm
vn ex -r -- docker swarm join --token $DOCKER_SWARM_WORKER_TOKEN $(vm ip lxcm01):2377
# remove all nodes from the swarm
vn ex -r docker swarm leave
```

[00]: source_me.sh
[01]: https://docs.docker.com/engine/reference/builder/ "Dockerfile reference"
[02]: var/aliases/
[03]: https://saltstack.com
[04]: https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html
[05]: https://docs.docker.com/install/
[13]: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.docker.html
[14]: https://docs.docker.com/registry/deploying/
[15]: srv/salt/docker/registry-docker-container.sls
[17]: https://docs.docker.com/registry/insecure/
[18]: https://hub.docker.com/u/prom/ "Prometheus on DockerHub"
[20]: srv/salt/docker/docker-daemon-insecure.sls
[21]: srv/salt/docker/docker-daemon-insecure.json
[22]: var/aliases/prometheus.sh
[23]: srv/salt/prometheus/prometheus-docker-container.sls
[24]: https://github.com/prometheus/prometheus
[25]: https://github.com/prometheus/node_exporter
[26]: https://docs.docker.com/config/thirdparty/prometheus/
[27]: srv/salt/prometheus/prometheus-node-exporter-docker-container.sls
[28]: srv/salt/prometheus/prometheus.yml
[29]: https://docs.docker.com/engine/swarm/ "Docker Swarm mode overview"
[30]: https://docs.docker.com/engine/swarm/swarm-mode/ "Run Docker Engine in swarm mode"
[31]: bin/salt-master-vm-instance
