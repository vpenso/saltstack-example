# Docker Swarm

Deploy a [Docker Swarm Cluster][29] using following VMs: 

Node           | Description
---------------|------------------------------------
lxcm01         | docker, docker-registry, salt-master, prometheus
lxb00[1-3]     | docker (swarm nodes)

Start additional VMs and bootstrap Salt:

```bash
export NODES=lxb00[1-3]
# start additional nodes part or the Docker swarm cluster
vn s centos7
# add the SaltStack package repository
vn sy -r $SALT_EXAMPLE_PATH/etc/yum.repos.d/salt.repo  :/etc/yum.repos.d/
# install the SaltStack minions
vn ex -r "
        # disable the firewall
        systemctl disable --now firewalld
        yum install -y salt-minion
        # connte to the salt-master
        echo master: $(vm ip lxcm01) > /etc/salt/minion
        systemctl enable --now salt-minion && systemctl status salt-minion
"
```

Configure the nodes using the salt-master:

```bash
vm ex lxcm01 -r '
        # accept all Salt minions
        docker exec salt-master salt-key -A -y
        # install Docker CE on all nodes
        docker exec salt-master salt -t 300 -E lxb state.apply docker/docker-ce
'
```

Cf. [Run Docker Engine in swarm mode][30]:

```bash
# create a Docker swarm manager
vm ex lxcm01 -r -- docker swarm init --advertise-addr $(vm ip lxcm01)
# export the join token to an environment variable
export DOCKER_SWARM_WORKER_TOKEN=$(vm ex lxcm01 -r -- docker swarm join-token --quiet worker)
# add nodes to the swarm
vn ex -r -- docker swarm join --token $DOCKER_SWARM_WORKER_TOKEN $(vm ip lxcm01):2377
# remove all nodes from the swarm
vn ex -r docker swarm leave
```

[29]: https://docs.docker.com/engine/swarm/ "Docker Swarm mode overview"
[30]: https://docs.docker.com/engine/swarm/swarm-mode/ "Run Docker Engine in swarm mode"
