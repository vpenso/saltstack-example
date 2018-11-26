## SaltStack Master Deployment

This example uses a virtual machine setup with [vm-tools][16]:

```bash
# start a CentOS 7 VM instance and apply a basic configuration
vm s centos7 $SALT_MASTER
vm ex $SALT_MASTER -r '
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

### Salt-Minion & Docker CE

Install Salt minion on local host, and **run Salt [masterless][04] to install [Docker CE][05]**:

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
vm ex $SALT_MASTER -r '
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

**Build and run the "salt-master"** docker container:

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


[04]: https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html
[05]: https://docs.docker.com/install/
[06]: srv/salt/docker/docker-ce.sls
[07]: srv/salt/docker/docker-ce.repo
[08]: etc/yum.repos.d/salt.repo
[09]: var/aliases/salt.sh
[10]: var/dockerfiles/salt-master
[11]: var/aliases/docker.sh
[12]: srv/salt/salt/salt-master-docker-container.sls
[16]: https://github.com/vpenso/vm-tools