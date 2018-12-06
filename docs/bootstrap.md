### Bootstrap Salt Minion

Start from a basic CentOS 7 installation:

1. Sync this repository into the VM instance 
2. Make sure that the **SaltStack [package repository][repo]** is in the Yum configuration.
3. Enable the **EPEL Fedora community packages**
4. Install the **Salt Minion** package, and a couple of other required tools (i.e. Git)

```bash
vm sy $SALT_MASTER -r $SALT_EXAMPLE_PATH :/opt
vm ex $SALT_MASTER -r "echo 'source /opt/${SALT_REPO##*/}/source_me.sh' >> ~/.bashrc"
vm ex $SALT_MASTER -r '
        cp $SALT_EXAMPLE_PATH/etc/yum.repos.d/salt.repo /etc/yum.repos.d/
        yum install --assumeyes epel-release
        yum install --assumeyes salt-minion git bash-completion jq
'
```

[repo]: https://docs.saltstack.com/en/latest/topics/installation/rhel.html

### Salt Masterless Mode

Once the minion is installed, use masterless mode to configure other components:

```bash
salt-call --local --file-root $SALT_STATE_TREE state.sls <file>
```

[var/aliases/salt.sh][01] defines a shell function `salt-local` abbreviating the command above:

```bash
# i.e. install Docker Community Edition
salt-local docker/docker-ce
```

[01]: ../var/aliases/salt.sh

