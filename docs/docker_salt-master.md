
## Salt-Master Container 

Login to the VM, and build/run the salt-master container using the Docker CLI:

```bash
# build a new salt-master container
>>> docker build -t salt-master $SALT_EXAMPLE_PATH/var/dockerfiles/salt-master/
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

**Build and run the "salt-master"** docker container:

File                                                  | Description
------------------------------------------------------|-----------------------------------------
[var/aliases/docker.sh][11]                           | Shell functions for Docker
[var/dockerfiles/salt-master/Dockerfile][10]          | Dockerfile for the Salt master
[srv/salt/salt/salt-master-docker-container.sls][12]  | Salt state file to build & run salt-master container


Execute masterless Salt to build and start the salt-master container on localhost:

```bash
vm ex $SALT_MASTER -r salt-call-local-state salt/salt-master-docker-container
```

Using following Salt configuration (cf. [salt-master-docker-container.sls][12]):

```sls
docker_build_salt_master:
  docker_image.present:
    - name: salt-master
    - build: {{ salt['environ.get']('SALT_EXAMPLE_PATH') }}/var/dockerfiles/salt-master
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
