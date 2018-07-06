# SaltStack Docker Deployment

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

**Boostrap localhost to run a Salt master as a service in a Docker container:**

1. Install Salt minion on the host
2. Run Salt [masterless][04] to install [Docker CE][05]
3. Build a Salt Master Docker container image
4. Run the `salt-master` service container to **serve a local Salt state tree** [srv/salt](srv/salt)

The shell script [source_me.sh][00] adds the shell functions in [var/aliases/\*.sh][02] to the environment.

## Docker

File                 | Description
---------------------|-----------------------------------------
[salt.sh][09]        | Shell functions for SaltStack
[salt.repo][08]      | SaltStack Yum repository configuration
[docker-ce.repo][07] | Docker CE Yum repository configuration
[docker-ce.sls][06]  | Salt state file to install Docker CE

```bash
# load the shell functions
>>> source source_me.sh
# bootstrap salt-minion on localhost
>>> salt-bootstrap-minion
Add SaltStack repository to Yum in /etc/yum.repos.d/salt.repo
Install salt-minion with Yum, cf. /root/saltstack-docker/var/log/yum.log
# use salt to install Docker
>>> salt-call-local-state-docker 
Exec masterless Salt to install Docker CE, cf. /root/saltstack-docker/var/log/salt.log
```

## Salt Master

File                               | Description
-----------------------------------|-----------------------------------------
[docker.sh][11]                    | Shell functions for Docker
[salt-master/Dockerfile][10]       | Dockerfile for the Salt master
[master-docker-container.sls][12]  | Salt state file build & start salt-master

Build and start the salt-master container with the docker CLI:

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

Alternatively use salt instead:

```bash
# exec masterless Salt to build and start the salt-master container
>>> salt-call-local-state salt/master-docker-container
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

