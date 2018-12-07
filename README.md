List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

# SaltStack

Bootstrap a VM instance and deploy a **Salt** (cf. [docs/bootstrap.md](docs/bootstrap.md)):

```bash
# create the Salt master VM instance
salt-master-vm-instance
# Login to the Salt master
vm lo $SALT_MASTER -r
# deploy Docker CE on the master
vm ex $SALT_MASTER -r salt-local docker/docker-ce
```

[docs/docker.md](docs/docker.md) describes to deployment of the docker runtime on the master.

Proceed by installing more services:

* [docs/docker_salt-master.md](docs/docker_salt-master.md) - Salt-master in a Docker container
* [docs/prometheus.md](docs/prometheus.md)
* [docs/docker_registry.md](docs/docker_registry.md)
* [docs/docker_swarm.md](docs/docker_swarm.md)
