# SaltStack and Docker: Examples

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>
Prometheus | Time-series database          | <https://prometheus.io>

This example uses a virtual machine setup with [vm-tools][16]:

```bash
# start a CentOS 7 virtual machine instance
vm s centos7 lxcm01
# prepare the VM
vm ex lxcm01 -r '
        # diable the firewall
        systemctl disable --now firewalld
        # install Git
        yum install -qy git bash-completion
        # clone this repository
        git clone https://github.com/vpenso/saltstack-docker-example
        # load the repository environment on login
        echo "source $HOME/saltstack-docker-example/source_me.sh" >> $HOME/.bashrc
'
```

# SaltStack

Bootstrap the VM to run a Salt master as a service in a Docker container.

### Salt-Minion & Docker CE

Install Salt minion on local host, and run Salt [masterless][04] to install [Docker CE][05]:

File                                    | Description
----------------------------------------|-----------------------------------------
[etc/yum.repos.d/salt.repo][08]         | SaltStack Yum repository configuration
[var/aliases/salt.sh][09]               | Shell functions for SaltStack
[srv/salt/docker/docker-ce.repo][07]    | Docker CE Yum repository configuration
[srv/salt/docker/docker-ce.sls][06]     | Salt state file to install Docker CE

Use following shell functions to install Salt and Docker CE:

- [salt-bootstrap-minion()][09] - Install the salt-minion package on localhost
- [salt-call-local-state-docker()][09] - Install Docker CE on localhost using masterless Salt
- [salt-call-local-state()][09] - Exec masterless Salt with given Salt state file

```bash
# bootstrap Salt and Docker on localhost 
vm ex lxcm01 -r '
        salt-bootstrap-minion
        salt-call-local-state-docker
'
```

Docker CE is installed with following Salt configuration (cf [docker-ce.sls][06]):

```sls
# add the official Docker package repositories to Yum
docker_ce_package_repo:
  file.managed:
    - name: /etc/yum.repos.d/docker-ce.repo
    - source: salt://docker/docker-ce.repo

# install the Docker CE packages including dependecies
docker_ce_packages:
  pkg.latest:
    - refresh: True
    - pkgs:
      - yum-utils
      - device-mapper-persistent-data
      - lvm2
      - docker-ce
      - docker-python

# make sure docker daemon is present
docker_service:
  service.running:
    - name: docker.service
    - enable: True
```

### Salt-Master Container 

Build and run the "salt-master" docker container:

File                                                  | Description
------------------------------------------------------|-----------------------------------------
[var/aliases/docker.sh][11]                           | Shell functions for Docker
[var/dockerfiles/salt-master/Dockerfile][10]          | Dockerfile for the Salt master
[srv/salt/salt/salt-master-docker-container.sls][12]  | Salt state file to build & run salt-master container


Execute masterless Salt to build and start the salt-master container on localhost:

```bash
vm ex lxcm01 -r salt-call-local-state salt/salt-master-docker-container
```

Using following Salt configuration (cf. [salt-master-docker-container.sls][12]):

```sls
docker_build_salt_master:
  docker_image.present:
    - name: salt-master
    - build: {{ salt['environ.get']('SALT_DOCKER_PATH') }}/var/dockerfiles/salt-master
    - tag: latest

docker_run_salt_master:
  docker_container.running:
    - name: salt-master
    - image: salt-master:latest
    - restart_policy: always
    - port_bindings:
      - 4505:4505
      - 4506:4506
    - binds:
      - {{ salt['environ.get']('SALT_STATE_TREE') }}:/srv/salt:ro
```

Alternatively login to the VM to build and run the salt-master container using the Docker CLI:

```bash
# build a new salt-master container
>>> docker build -t salt-master $SALT_DOCKER_PATH/var/dockerfiles/salt-master/
>>> docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
salt-master         latest              af328deacce0        50 seconds ago      482MB
centos              latest              49f7960eb7e4        4 weeks ago         200MB
# start the salt-master service as docker container
>>> docker run --detach \
               --name salt-master \
               --publish 4505:4505 \
               --publish 4506:4506 \
               --volume $SALT_STATE_TREE/:/srv/salt \
           salt-master
>>> docker ps
# check the service log
>>> docker exec salt-master cat /var/log/salt/master
# inspect the salt-master container
>>> docker container inspect salt-master
```

The commands above are wrapped by the follwoing shell functions:

- [docker-build-salt-master()][11] -  Build the salt-master container image
- [docker-run-salt-master()][11] - Run salt-master service container
- [docker-attach-salt-master()][11] - Attach to the salt-master daemon console
- [docker-container-remove-all()][11] - Stop & remove all containers on localhost

# Docker Registry

Deploy a [Docker registry server][14] container:

File                                       | Description
-------------------------------------------|-----------------------------------------
[srv/salt/docker/registry-docker-container.sls][15] | Salt state file to pull & run a Docker registry container
[srv/salt/docker/docker-daemon-insecure.sls][20]    | Salt state to configure Docker daemon
[srv/salt/docker/docker-daemon-insecure.json][21]   | Docker daemon configuration file

1. [Test an insecure registry][17] by configuring Docker daemon to disregard security for the local registry
2. Install a Docker registry container from DockerHub
3. Copy container images from DockerHub to the private registry
4. Show the repositories on the private registry

```bash
# exec masterless Salt to pull and run the Docker private registry container
salt-call-local-state docker/registry-docker-container
# allow docker daemon insecure acccess to the local registry
salt-call-local-state docker/docker-daemon-insecure
# pull, tag, and push prometheus and node-exporter container images
prometheus-dockerhub-images-to-local-registry
# list repos in local registry
docker-list-local-repository-catalog
```

Manual configuration:

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
[var/aliases/prometheus.sh][22]                             | Shell functions for Prometheus
[srv/salt/prometheus/prometheus-docker-container.sls][23]   | Salt state to configure the Prometheus docker container

```bash
# exec masterless Salt to run a Prometheus docker container
vm ex lxcm01 -r salt-call-local-state prometheus/prometheus-docker-container
# access Prometheus WUI from the VM host
$BROWSER http://$(vm ip lxcm01):9090/targets
```

Run the containers using the Docker CLI:

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



[Collect Docker metrics with Prometheus][26]

[00]: source_me.sh
[01]: https://docs.docker.com/engine/reference/builder/ "Dockerfile reference"
[02]: var/aliases/
[03]: https://saltstack.com
[04]: https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html
[05]: https://docs.docker.com/install/
[06]: srv/salt/docker/docker-ce.sls
[07]: srv/salt/docker/docker-ce.repo
[08]: etc/yum.repos.d/salt.repo
[09]: var/aliases/salt.sh
[10]: var/dockerfiles/salt-master
[11]: var/aliases/docker.sh
[12]: srv/salt/salt/master-docker-container.sls
[13]: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.docker.html
[14]: https://docs.docker.com/registry/deploying/
[15]: srv/salt/docker/registry-docker-container.sls
[16]: https://github.com/vpenso/vm-tools
[17]: https://docs.docker.com/registry/insecure/
[18]: https://hub.docker.com/u/prom/
[20]: srv/salt/docker/docker-daemon-insecure.sls
[21]: srv/salt/docker/docker-daemon-insecure.json
[22]: var/aliases/prometheus.sh
[23]: srv/salt/prometheus/prometheus-docker-container.sls
[24]: https://github.com/prometheus/prometheus
[25]: https://github.com/prometheus/node_exporter
[26]: https://docs.docker.com/config/thirdparty/prometheus/
