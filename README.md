List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

# SaltStack

Bootstrap a VM instance and deploy **Salt** (cf. [docs/bootstrap.md](docs/bootstrap.md)):

```bash
# create the Salt master VM instance
salt-vm-instance
# create a VM instance with salt-minion installed
salt-vm-instance <name>
# Login to the Salt master
vm lo $SALT_MASTER -r
```

Install/configure the `salt-master`:

* [docs/salt-master.md](docs/salt-master.md) - Install the salt-master 
* [docs/docker_salt-master.md](docs/docker_salt-master.md) - Salt-master in a Docker container

Salt configuration and state files:

File(s)                                   | Description
------------------------------------------|------------------------------------------
[srv/salt/](srv/salt/)                    | The **state tree** includes all SLS (SaLt State file) representing the state in which all nodes should be
[etc/salt/master](etc/salt/master)        | Salt master configuration (`file_roots` defines to location of the state tree)
[srv/salt/top.sls](srv/salt/top.sls)      | Maps nodes to SLS configuration files (cf. [top file][tf])

[tf]: https://docs.saltstack.com/en/latest/ref/states/top.html

```bash
# sync this repository with the salt-master VM instance
vm sy $SALT_MASTER -r $SALT_EXAMPLE_PATH :/opt |:
```

### Service

Proceed by installing more services:

* [docs/docker.md](docs/docker.md) - Install the Docker runtime
* [docs/docker_prometheus.md](docs/dicker_prometheus.md) - Prometheus server in a Docker container
* [docs/docker_registry.md](docs/docker_registry.md) - Docker Registry in a Docker container
* [docs/docker_swarm.md](docs/docker_swarm.md) - Docker Swarm cluster
