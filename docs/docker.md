[Bootstrap](bootstrap.md) the salt minion for masterless mode beforehand.

### Docker Runtime

Manual installation of the Docker runtime:

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

Use Salt to install the Docker runtime:

File                                    | Description
----------------------------------------|-----------------------------------------
[srv/salt/docker/docker-ce.repo][07]    | Docker CE Yum repository configuration
[srv/salt/docker/docker-ce.sls][06]     | Salt state file to install Docker CE

Login to the VM and use Salt masterless mode:

```bash
# run salt masterless to install Docker
salt-call --local --file-root $SALT_STATE_TREE state.sls docker/docker-ce
# check the Docker installation
docker info
```

Alternatively use the shell function from [var/aliases/salt.sh](../var/aliases/salt.sh)

```bash
vm ex $SALT_MASTER -r  salt-local docker/docker-ce
```

[06]: srv/salt/docker/docker-ce.sls
[07]: srv/salt/docker/docker-ce.repo
