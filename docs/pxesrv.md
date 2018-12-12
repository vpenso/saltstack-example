
# PXESrv

[PXESrv][01] is an HTTP server hosting iPXE network boot configurations.

File                         | Description
-----------------------------|-------------------------------------------
[srv/salt/pxesrv.sls][02]    | Salt state file to install PXESrv as Dcoker container

```bash
instance=lxcm02 
# start a VM instance (make sure to accept the salt-minion key on the master)
salt-vm-instance -m $SALT_MASTER $instance
# install PXESrv
vm ex $SALT_MASTER -r -- salt -E $instance state.apply pxesrv
```

iPXE boot configuration is hosted in `/srv/pxesrv`.

## PXE Boot

```bash
instance=lxdev01
# start a VM instance with PXE boot enabled
vm shadow --net-boot --memory 2 centos7 $instance
# access the VM instance console
vm view $instance &
```

Use **ctrl-b** to access the iPXE shell:

```bash
# start the network interface
dhcp
# query the PXESrv boot server
chain http://lxcm02.devops.test:4567/redirect
```

[01]: https://github.com/vpenso/pxesrv
[02]: ../srv/salt/pxesrv.sls
