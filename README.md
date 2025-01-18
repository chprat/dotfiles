# dotfiles

This repository contains the dotfiles (common configuration files within the
Linux home directory) and some configuration hints for other services.

## Requirements to work with the repository

*git* is required to clone the repository. The *setup.sh* script relies on
*sudo* to gain elevated privileges. It's usually enough to add the user to the
*sudo* or *wheel* (depends on the distribution) group and relog. The script is
also only tested on Debian/Ubuntu based distributions.

```bash
su -c usermod -aG sudo <username>
sudo apt update && sudo apt install -y git
```

### Running the linters

Linting is done with the [MegaLinter](https://megalinter.io/) in this
repository. If you want to run it locally, you can use
[act](https://github.com/nektos/act) to execute the GitHub pipeline on your
device. *act* requires *docker*, follow [Install docker](#install-docker) for a
guide how to install it.

## Install docker

To install *docker* from the default repositories, execute the following
commands:

```bash
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

The included version is usually a little dated and there a lot of instructions
can be found online to install a version from
[docker.com](https://www.docker.com/).

## Gnome shell extensions

These extensions for gnome shell are helpful:

- [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [Freon](https://extensions.gnome.org/extension/841/freon/) (requires
  lm-sensors)
- [Resource Monitor](https://extensions.gnome.org/extension/1634/resource-monitor/)
  (replaces Freon & Simple monitor)
- [Simple monitor](https://extensions.gnome.org/extension/3891/simple-monitor/)
- [Sound Input & Output Device Chooser](https://extensions.gnome.org/extension/906/sound-output-device-chooser/)

You need to install `gnome-browser-connector` and a browser plugin for easy
single-click installation.

## NFS configuration for network boot

This configuration is used to boot embedded devices via NFS. The file is
`/etc/exports`

```text
/srv/nfs <network-address>/<network-mask>(no_root_squash,no_subtree_check,rw)
```

## TLP configuration to restore device state on boot

This setting will restore the device state (of WiFi, Bluetooth or 3/4/5G radio
devices) on boot. The file is
`/etc/tlp/01-restore-device-state-on-startup.conf`

```text
RESTORE_DEVICE_STATE_ON_STARTUP=1
```

## Yocto site configuration

This configuration can be included in Yocto and will be enabled only on your
PC. The file is `$HOME/.yocto/site.conf`

```text
DL_DIR = "<download-directory>"
SSTATE_DIR = "<sstate-directory>"
IMAGE_FSTYPES_append = " tar.gz"
BB_NUMBER_THREADS ?= "${@int(oe.utils.cpu_count()/4)}"
PARALLEL_MAKE ?= "-j ${@int(oe.utils.cpu_count()/4)}"
```

## LabGrid .bashrc aliases

These commands will simplify the usage of LabGrid in multiple locations with
different LabGrid servers. They go in your `$HOME.bashrc` and are untested.

```bash
alias lgcomp='. <path-to-labgrid>/labgrid/contrib/completion/labgrid-client.bash && complete -F _labgrid_client lgc'
alias lgc='labgrid-client'
alias lgs='. <path-to-labgrid>/labgrid-venv/bin/activate'
function lghome () { export LG_CROSSBAR="ws://<srv1>:20408/ws" && export LG_PLACE=<place> && export LG_ENV=<environment>.yaml && lgs && lgcomp ; }
function lgoffice () { export LG_CROSSBAR="ws://<srv2>:20408/ws" && export LG_PLACE=<place> && export LG_ENV=<environment>.yaml && lgs && lgcomp ; }
```

## Helpful one-liners

Find all (identical) duplicates and delete the ones in the `v2` directory:

```bash
fdupes -r . |grep "./v2" |xargs -d'\n' rm
```

Find all files bigger than 1 GB in the current directory and sub-directories:

```bash
find . -type f -size +1G
```

Get the size of all files/folders in current directory and sort them by size:

```bash
for i in *; do du -sh "$i"; done |sort -hr
```
