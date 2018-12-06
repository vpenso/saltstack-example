## Bootstrap

Start from a basic CentOS 7 installation:

1. Make sure that the **SaltStack [package repository][repo]** is in the Yum configuration.
2. Enable the **EPEL Fedora community packages**
3. Install the **Salt Minion** package, and a couple of other required tools (i.e. Git)
4. Sync this repository into the VM instance 

```bash
vm sy $SALT_MASTER -r $SALT_EXAMPLE_PATH/etc/yum.repos.d/salt.repo :/etc/yum.repso.d/
vm ex $SALT_MASTER -r '
        yum install --assumeyes epel-release
        yum install --assumeyes salt-minion git bash-completion jq
'
vm sy $SALT_MASTER -r $SALT_EXAMPLE_PATH :/opt
vm ex $SALT_MASTER -r "echo 'source /opt/${SALT_REPO##*/}/source_me.sh' >> ~/.bashrc"
```

[repo]: https://docs.saltstack.com/en/latest/topics/installation/rhel.html

Once the Salt minion is installed, use its masterless mode to prepare Docker:

1. **Clone this Git repository** to make the required Salt configuration available on the host
2. Add the cloned repository to the shell environment. It defines among others the `SALT_STATE_TREE` environment variable.
3. **Install Docker** on the host with `salt-call --local` (masterless) and an SLS from the repository.


```bash
# run salt masterless to install Docker
salt-call --local --file-root $SALT_STATE_TREE state.sls docker/docker-ce
# check the Docker installation
docker info
```

Docker CE is installed with following Salt configuration, cf. [docker-ce.sls](../srv/salt/docker/docker-ce.sls):

```sls
# add the official Docker package repositories to Yum
docker_ce_package_repo:
  file.managed:
    - name: /etc/yum.repos.d/docker-ce.repo
    - source: salt://docker/docker-ce.repo

# install the Docker CE packages including dependecies
docker_ce_packages:
  pkg.latest:
    - refresh: True
    - pkgs:
      - yum-utils
      - device-mapper-persistent-data
      - lvm2
      - docker-ce
      - docker-python

# make sure docker daemon is present
docker_service:
  service.running:
    - name: docker.service
    - enable: True
```

Now proceed by building a docker container for the Salt master.
