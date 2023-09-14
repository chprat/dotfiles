# dotfiles

This repository contains the dotfiles (common configuration files within the Linux home directory) and some configuration hints for other services.

## NFS configuration for network boot
This configuration is used to boot embedded devices via NFS. The file is `/etc/exports`
```
/srv/nfs <network-address>/<network-mask>(no_root_squash,no_subtree_check,rw)
```
