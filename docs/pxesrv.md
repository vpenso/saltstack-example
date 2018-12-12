
# PXESrv

[PXESrv][01] is an HTTP server hosting iPXE network boot configurations.

File                         | Description
-----------------------------|-------------------------------------------
[srv/salt/pxesrv.sls][02]    | Salt state file to install PXESrv as Docker container

```bash
instance=lxcm02 
# start a VM instance (make sure to accept the salt-minion key on the master)
salt-vm-instance -m $SALT_MASTER $instance
# install PXESrv
vm ex $SALT_MASTER -r -- salt -E $instance state.apply pxesrv
```

The SLS above will bind the host `/srv/pxesrv` directory into the pxesrv container.

## Configuration

Publish an [iPXE configuration][ipxe] on the VM instance hosting PXESrv:

```bash
vm sy lxcm02 -r $PXESRV_ROOT/ :/srv/pxesrv
```

An [iPXE example configuration][ipxec] is available in the [PXESrv][01] repository.

[ipxe]: http://ipxe.org/docs
[ipxec]: https://github.com/vpenso/pxesrv/tree/master/public

## Network Boot

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
