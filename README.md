# SaltStack and Docker: Examples

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

This example uses a virtual machine setup with [vm-tools][16]:

```bash
# start a CentOS 7 virtual machine instance
vm s centos7 lxcm01
# install VCS and clone this repository
vm ex lxcm01 -r '
        yum install -qy git bash-completion
        git clone https://github.com/vpenso/saltstack-docker-example
'
# login as root
vm lo lxcm01 -r
# change to the repository
[root@lxcm01 ~] cd saltstack-docker-example/
# source the environment
[root@lxcm01 saltstack-docker-example] source source_me.sh 
SALT_DOCKER_PATH=/root/saltstack-docker-example
...
```

# SaltStack

**Boostrap localhost to run a Salt master as a service in a Docker container:**

1. Install Salt minion on the host
2. Run Salt [masterless][04] to install [Docker CE][05]
3. Build a Salt Master Docker container image
4. Run the `salt-master` service container to **serve a local Salt state tree** [srv/salt](srv/salt)

### Salt-Minion & Docker CE

Required files:

File                                    | Description
----------------------------------------|-----------------------------------------
[var/aliases/salt.sh][09]               | Shell functions for SaltStack
[etc/yum.repos.d/salt.repo][08]         | SaltStack Yum repository configuration
[srv/salt/docker/docker-ce.repo][07]    | Docker CE Yum repository configuration
[srv/salt/docker/docker-ce.sls][06]     | Salt state file to install Docker CE

Command to execute:

```bash
# bootstrap salt-minion on localhost
>>> salt-bootstrap-minion
Add SaltStack repository to Yum in /etc/yum.repos.d/salt.repo
Install salt-minion with Yum, cf. $SALT_DOCKER_LOGS/yum.log
# use salt to install Docker
>>> salt-call-local-state-docker 
Exec masterless Salt to install Docker CE, cf. $SALT_DOCKER_LOGS/salt.log
```

### Salt-Master Container 

Build and run the "salt-master" docker container:

File                                             | Description
-------------------------------------------------|-----------------------------------------
[var/aliases/docker.sh][11]                      | Shell functions for Docker
[var/dockerfiles/salt-master/Dockerfile][10]     | Dockerfile for the Salt master
[srv/salt/salt/master-docker-container.sls][12]  | Salt state file to build & run salt-master container

```bash
# exec masterless Salt to build and start the salt-master container
>>> salt-call-local-state salt/master-docker-container
# inspect the salt-master container
>>> docker container inspect salt-master
```

Manual configuration

```bash
# build a new salt-master container
>>> docker-build-salt-master
# show the generated container images
>>> docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
salt-master         latest              af328deacce0        50 seconds ago      482MB
centos              latest              49f7960eb7e4        4 weeks ago         200MB
# start the salt-master service as docker container
>>> docker-run-salt-master
Start salt-master container...
1eb0156818119156fb0de66a65348ca70f596df5b386b3e3ad82e1c54a2cb59c
# check if the container is running
>>> docker ps
# check the service log
>>> docker exec salt-master cat /var/log/salt/master
# attach to the container console
>>> docker-attach-salt-master
Detach with ctrl-p ctrl-q
...
```


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
# the following function will pull, tag, and push for the
# prometheus and node-exporter container images
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

File                                       | Description
-------------------------------------------|-----------------------------------------
[var/aliases/prometheus.sh][22]            | Shell functions for Prometheus

```bash
# start the Prometheus container from the private registry
docker run --interactive \
           --tty --rm \
           --name prometheus \
           --publish 9090:9090 \
           --volume $SALT_STATE_TREE/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
           $DOCKER_LOCAL_REGISTRY/prometheus:$PROMETHEUS_VERSION
```


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
