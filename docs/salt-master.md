
```bash
vm ex $SALT_MASTER -r '
        yum install -y salt-master
        systemctl enable --now salt-master
'
```
