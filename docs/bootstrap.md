
File                                    | Description
----------------------------------------|-----------------------------------------
[bin/salt-vm-instance][02]              | Create a VM instance with the Salt minion installed
[etc/yum.repos.d/salt.repo][08]         | SaltStack Yum repository configuration
[var/aliases/salt.sh][09]               | Shell functions for Salt


## Bootstrap 

This example uses a virtual machine setup with [vm-tools][00]:

```bash
# start a CentOS 7 VM instance and apply a basic configuration
vm s centos7 $SALT_MASTER
vm ex $SALT_MASTER -r "
        # diable the firewall
        systemctl disable --now firewalld
        # install Git
        yum install -y git bash-completion
"
```

[00]: https://github.com/vpenso/vm-tools

### Salt Deployment

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

[bin/salt-vm-instance][02] automates the steps above.

### Salt Masterless Mode

Once the minion is installed, use [masterless mode][mm] to configure other components:

[mm]: https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html

```bash
salt-call --local --file-root $SALT_STATE_TREE state.sls <file>
```

[var/aliases/salt.sh][01] defines a shell function `salt-local` abbreviating the command above:

```bash
# i.e. install Docker Community Edition
vm ex $SALT_MASTER -r salt-local docker/docker-ce
```

[01]: ../var/aliases/salt.sh
[02]: ../bin/salt-vm-instance
[08]: etc/yum.repos.d/salt.repo
[09]: var/aliases/salt.sh
