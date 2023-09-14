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

## Yocto site configuration
This configuration can be included in Yocto and will be enabled only on your PC. The file is `$HOME/.yocto/site.conf`
```
DL_DIR = "<download-directory>"
SSTATE_DIR = "<sstate-directory>"
IMAGE_FSTYPES_append = " tar.gz"
BB_NUMBER_THREADS ?= "${@int(oe.utils.cpu_count()/4)}"
PARALLEL_MAKE ?= "-j ${@int(oe.utils.cpu_count()/4)}"
```

## Hide files in nautilus
To hide files or folder in nautilus, without prepending a dot to the file name, you can create a file named `.hidden` in the folder and add the the files/folders to hide (one file/folder per line).

## LabGrid .bashrc aliases
These commands will simplify the usage of LabGrid in multiple locations with different LabGrid servers. They go in your `$HOME.bashrc` and are untested.
```
alias lgcomp='. <path-to-labgrid>/labgrid/contrib/completion/labgrid-client.bash && complete -F _labgrid_client lgc'
alias lgc='labgrid-client'
alias lgs='. <path-to-labgrid>/labgrid-venv/bin/activate'
function lghome () { export LG_CROSSBAR="ws://<srv1>:20408/ws" && export LG_PLACE=<place> && export LG_ENV=<environment>.yaml && lgs && lgcomp ; }
function lgoffice () { export LG_CROSSBAR="ws://<srv2>:20408/ws" && export LG_PLACE=<place> && export LG_ENV=<environment>.yaml && lgs && lgcomp ; }
```
