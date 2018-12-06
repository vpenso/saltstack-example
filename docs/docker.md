[Bootstrap](bootstrap.md) the salt minion for masterless mode beforehand.

### Docker Runtime

Manuall installation of the Docker runtime:

```bash
vm ex $SALT_MASTER -r '
        # install the Yum repo configuration
        cp $SALT_EXAMPLE_PATH/srv/salt/docker/docker-ce.repo /etc/yum.repos.d/
        # install packages
        yum install -y yum-utils device-mapper-persistent-data lvm2 docker-ce docker-python
        # start Docker
        systemctl enable --now docker && docker info
'
```

The following Salt configuration (cf. [docker-ce.sls](../srv/salt/docker/docker-ce.sls)) replicates the steps above:

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

Instead of a manual configuration use Salt masterless mode:

```bash
# run salt masterless to install Docker
salt-call --local --file-root $SALT_STATE_TREE state.sls docker/docker-ce
# check the Docker installation
docker info
```

