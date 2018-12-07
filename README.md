List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
SaltStack  | Infrastructure orchestration  | <https://saltstack.com>
Docker     | Container Management          | <https://docker.com>

# SaltStack

Bootstrap a VM instance and deploy a **Salt** (cf. [docs/bootstrap.md](docs/bootstrap.md)):

File                                    | Description
----------------------------------------|-----------------------------------------
[bin/salt-master-vm-instance][01]       | Create VM `$SALT_MASTER` and install the Salt minion
[etc/yum.repos.d/salt.repo][08]         | SaltStack Yum repository configuration
[var/aliases/salt.sh][09]               | Shell functions for Salt

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

[01]: bin/salt-master-vm-instance
[08]: etc/yum.repos.d/salt.repo
[09]: var/aliases/salt.sh
