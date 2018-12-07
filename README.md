List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

# SaltStack

Bootstrap a VM instance and deploy **Salt** (cf. [docs/bootstrap.md](docs/bootstrap.md)):

```bash
# create a VM instance with salt-minion installed
salt-vm-instance $instance
# Login to the Salt master
vm lo $instance -r
```

Create/configure the **`salt-master` VM instance**

```bash
# create the Salt master VM instance (salt-minion, and repository installed)
salt-vm-instance $SALT_MASTER
# install the Salt master
vm ex $SALT_MASTER -r '
        yum install -y salt-master
        cp $SALT_EXAMPLE_PATH/etc/salt/master /etc/salt
        systemctl enable --now salt-master
'
```

Alternatively follow [docs/docker_salt-master.md][dsm]  to deploy the Salt master in a Docker container.

[dsm]: docs/docker_salt-master.md

### States

Salt configuration and state files:

File(s)                                   | Description
------------------------------------------|------------------------------------------
[srv/salt/](srv/salt/)                    | The **state tree** includes all SLS (SaLt State file) representing the state in which all nodes should be
[etc/salt/master](etc/salt/master)        | Salt master configuration (`file_roots` >> `/srv/salt` defines to location of the state tree)
[srv/salt/top.sls](srv/salt/top.sls)      | Maps nodes to SLS configuration files (cf. [top file][tf])

[tf]: https://docs.saltstack.com/en/latest/ref/states/top.html

**Sync the state tree** with the salt-master VM instance

```bash
vm sy $SALT_MASTER -r $SALT_EXAMPLE_PATH/srv/salt :/srv |:
```

### Minions

Connect a `salt-minion` to the `$SALT_MASTER` VM instance:

```bash
instance=lxdev01 # i.e.
# create a VM instance (including an installed salt-minion)
salt-vm-instance $instance
# configure/start the salt-minion
vm ex $instance -r "
        echo master: $(vm ip $SALT_MASTER) > /etc/salt/minion
        systemctl enable --now salt-minion
"
# accept the new salt-minion on the server
vm ex $SALT_MASTER -r -- salt-key -A -y
```

Configure a node:

```bash
# check if the node responds to the salt-master
vm ex $SALT_MASTER -r -- salt -E $instance test.ping
```

## Services

Proceed by installing more services:

* [docs/docker.md](docs/docker.md) - Install the Docker runtime
* [docs/docker_prometheus.md](docs/dicker_prometheus.md) - Prometheus server in a Docker container
* [docs/docker_registry.md](docs/docker_registry.md) - Docker Registry in a Docker container
* [docs/docker_swarm.md](docs/docker_swarm.md) - Docker Swarm cluster
