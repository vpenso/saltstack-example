## Bootstrap

Start from a basic CentOS 7 installation:

1. Make sure that the **SaltStack [package repository][repo]** is in the Yum configuration.
2. Enable the **EPEL Fedora community packages**
3. Install the **Salt Minion** package, and a couple of other required tools (i.e. Git)

```bash
cat > /etc/yum.repos.d/salt.repo <<EOF
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux $releasever
baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/base/RPM-GPG-KEY-CentOS-7
EOF
yum install --assumeyes epel-release
yum install --assumeyes salt-minion git bash-completion jq 
```

[repo]: https://docs.saltstack.com/en/latest/topics/installation/rhel.html

Once the Salt minion is installed, use its masterless mode to prepare Docker:

1. **Clone this Git repository** to make the required Salt configuration available on the host
2. Add the cloned repository to the shell environment. It defines among others the `SALT_STATE_TREE` environment variable.
3. **Install Docker** on the host with `salt-call --local` (masterless) and an SLS from the repository.

```bash
git clone https://github.com/vpenso/saltstack-docker-example
# append the repository environment othe the shell user-configuration
echo "source $(realpath $PWD)/saltstack-docker-example/source_me.sh" >> ~/.bashrc && source ~/.bashrc
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
