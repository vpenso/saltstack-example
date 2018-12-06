# Docker

Once the Salt minion is installed, use its masterless mode to prepare Docker.
**Install Docker** on the host with `salt-call --local` (masterless) and an 
SLS from the repository:

```bash
# run salt masterless to install Docker
salt-call --local --file-root $SALT_STATE_TREE state.sls docker/docker-ce
# check the Docker installation
docker info
```

Docker CE is installed with following Salt configuration, cf. [docker-ce.sls](../srv/salt/docker/docker-ce.sls):

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

Now proceed by building a docker container for the Salt master.
