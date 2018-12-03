List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>
Prometheus | Time-series database          | <https://prometheus.io>

# SaltStack with Docker

Bootstrap a VM instance and deploy a **Salt master as Docker container**:

File                                    | Description
----------------------------------------|-----------------------------------------
[bin/salt-master-vm-instance][01]       | Boot a VM with a Salt master docker container, cf. [INSTALL.md](INSTALL.md)

Login to the VM instance with `vm lo $SALT_MASTER -r`.

Proceed by installing more services:

* [docs/prometheus.md](docs/prometheus.md)
* [docs/docker_registry.md](docs/docker_registry.md)
* [docs/docker_swarm.md](docs/docker_swarm.md)

[01]: bin/salt-master-vm-instance
