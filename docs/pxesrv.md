

## PXESrv

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

[01]: https://github.com/vpenso/pxesrv
[02]: ../srv/salt/pxesrv.sls
