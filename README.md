List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>
Prometheus | Time-series database          | <https://prometheus.io>

# SaltStack with Docker

Bootstrap a VM instance and deploy a **Salt** (cf. [docs/bootstrap.md](docs/bootstrap.md)):

File                                    | Description
----------------------------------------|-----------------------------------------
[bin/salt-master-vm-instance][01]       | Create VM `$SALT_MASTER` and install the Salt minion
[etc/yum.repos.d/salt.repo][08]         | SaltStack Yum repository configuration
[var/aliases/salt.sh][09]               | Shell functions for Salt

Login to the VM instance with `vm lo $SALT_MASTER -r`.

Proceed by installing more services:

* [docs/prometheus.md](docs/prometheus.md)
* [docs/docker_registry.md](docs/docker_registry.md)
* [docs/docker_swarm.md](docs/docker_swarm.md)

[01]: bin/salt-master-vm-instance
[08]: etc/yum.repos.d/salt.repo
[09]: var/aliases/salt.sh
