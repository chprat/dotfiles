# dotfiles

This repository contains the dotfiles (common configuration files within the Linux home directory) and some configuration hints for other services.

## NFS configuration for network boot
This configuration is used to boot embedded devices via NFS. The file is `/etc/exports`
```
/srv/nfs <network-address>/<network-mask>(no_root_squash,no_subtree_check,rw)
```

## TLP configuration to restore device state on boot
This setting will restore the device state (of WiFi, Bluetooth or 3/4/5G radio devices) on boot. The file is `/etc/tlp/01-restore-device-state-on-startup.conf`
```
RESTORE_DEVICE_STATE_ON_STARTUP=1
```
