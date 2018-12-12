
# PXESrv

[PXESrv][01] is an HTTP server hosting iPXE network boot configurations.

File                         | Description
-----------------------------|-------------------------------------------
[srv/salt/pxesrv.sls][02]    | Salt state file to install PXESrv as Docker container

```bash
pxesrv=lxcm02 
# start a VM instance (make sure to accept the salt-minion key on the master)
salt-vm-instance -m $SALT_MASTER $pxesrv
# install PXESrv
vm ex $SALT_MASTER -r -- salt -E $pxesrv state.apply pxesrv
```

The SLS above will bind the host `/srv/pxesrv` directory into the pxesrv container.

### iPXE Configuration

Publish an [iPXE configuration][ipxe] on the VM instance hosting PXESrv:

```bash
vm sy $pxesrv -r $PXESRV_ROOT/ :/srv/pxesrv
```

An [iPXE example configuration][ipxec] is available in the [PXESrv][01] repository.

[ipxe]: http://ipxe.org/docs
[ipxec]: https://github.com/vpenso/pxesrv/tree/master/public

### PXE Network Boot

```bash
pxeclient=lxdev01
vm ex $pxesrv -r "
      mkdir -p /srv/pxesrv/link
      ln -s /srv/pxesrv/centos /srv/pxesrv/link/$(vm ip $pxeclient)
"
```

```bash
# start a VM instance with PXE boot enabled
vm shadow --net-boot --memory 2 centos7 $pxeclient
# access the VM instance console
vm view $pxeclient &
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
