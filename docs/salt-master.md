Install Saltstack on all nodes (cf. [Salt configuration][sc]):

[sc]: https://docs.saltstack.com/en/latest/ref/configuration/index.html

## Salt Master

Create/configure the salt-master VM instance

```bash
# create the Salt master VM instance
salt-vm-instance $SALT_MASTER
# install the Salt master
vm ex $SALT_MASTER -r "
        yum install -y salt-master
        ln -s /opt/${SALT_REPO##*/}/srv/salt/ /srv/salt
        systemctl enable --now salt-master
"
```

Alternatively: [docs/docker_salt-master.md][dsm] deploys a Salt master in a Docker container

[dsm]: docs/docker_salt-master.md 

### Salt Minion

Connect a salt-minioni (i.e. lxdev01) to the `$SALT_MASTER` VM instance:

```bash
# create a VM instance (including an installed salt-minion)
salt-vm-instance lxdev01
# configure/start the salt-minion
vm ex lxdev01 -r "
        echo master: $(vm ip $SALT_MASTER) > /etc/salt/minion
        systemctl enable --now salt-minion
"
# accespt the new salt-minion on the server
vm ex $SALT_MASTER -r -- salt-key -A -y
```

```bash

```
