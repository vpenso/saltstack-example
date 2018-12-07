## Salt Master

```bash
# create the Salt master VM instance
salt-vm-instance $SALT_MASTER
# install the Salt master
vm ex $SALT_MASTER -r '
        yum install -y salt-master
        systemctl enable --now salt-master
'
```

Alternatively: [docs/docker_salt-master.md][dsm] deploys a Salt master in a Docker container

[dsm]: docs/docker_salt-master.md 

### Salt Minion

Connect a salt-minion to the `$SALT_MASTER` VM instance

```bash
salt-vm-instance lxdev01
vm ex lxdev01 -r "
        echo master: $(vm ip $SALT_MASTER) > /etc/salt/minion
        systemctl enable --now salt-minion
"
```
