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
# deploy Docker CE on the master
vm ex $SALT_MASTER -r salt-local docker/docker-ce
```

Proceed by installing more services:

* [docs/salt-master.md](docs/salt-master.md) - Install the salt-master 
* [docs/docker.md](docs/docker.md) - Install the Docker runtime
* [docs/docker_salt-master.md](docs/docker_salt-master.md) - Salt-master in a Docker container
* [docs/docker_prometheus.md](docs/dicker_prometheus.md) - Prometheus server in a Docker container
* [docs/docker_registry.md](docs/docker_registry.md) - Docker Registry in a Docker container
* [docs/docker_swarm.md](docs/docker_swarm.md) - Docker Swarm cluster
