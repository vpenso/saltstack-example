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

[srv/salt/docker/docker-ce.sls](../srv/salt/docker/docker-ce.sls) state-file 
runs the commands above.Login to the VM an install Docker using Salt 
masterless mode:

```bash
# run salt masterless to install Docker
salt-call --local --file-root $SALT_STATE_TREE state.sls docker/docker-ce
# check the Docker installation
docker info
```

Alternatively use the shell function from [var/aliases/salt.sh](../var/aliases/salt.sh)

```bash
vm ex $SALT_MASTER -r '
        salt-local docker/docker-ce
        docker info
'
```

