# easier navigation
# shellcheck shell=bash
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# add ~/.local/bin to PATH
PATH="$PATH":"$HOME"/.local/bin

# cd .. multiple times
function cdn () {
    for _i in $(seq "$1"); do
        cd ..
    done
}

# create folder and cd into
function mcd () {
    mkdir -p "$1" && cd "$1" || return
}

# remove empty directories
function rme () {
    find . -type d -empty -print -delete
}

# update system
function sysupgr () {
    sudo apt update
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    dpkg -l |grep ^rc | awk '{ print $2 }' | xargs sudo apt purge -y
    if which snap > /dev/null; then
        sudo snap refresh
    fi
}

# copy files to NAS
function backup () {
    rsync -avhP --delete "$HOME/.ssh/" "$HOME/data/ssh"
    rsync -avhP --delete "$HOME/data/" "eq12:data/staging/$HOSTNAME"
}

# overwrite local files from NAS
function serversync () {
    rsync -avhP --delete eq12:/data/ "$HOME/data/"
}

# Yocto directory exports FAG
function fagexports () {
    export DL_DIR=/var/yocto/fag/kirkstone-downloads-cache
    export SSTATE_DIR=/var/yocto/fag/kirkstone-sstate-cache
}

# start webex in X11 session
function webex () {
    XDG_SESSION_TYPE=x11 /opt/Webex/bin/CiscoCollabHost
}

# find Yocto rootfs archive
function getRFS () {
    find build/tmp**/deploy/images/ -iname "*rootfs.tar.gz"
}

# extract Yocto rootfs archive
function exRFS () {
    rm -rf rootfs
    mkdir rootfs
    tar xf "$(getRFS)" -C rootfs
}

# enable autojump
# shellcheck source=/dev/null
source /usr/share/autojump/autojump.sh

# enable fzf
# shellcheck source=/dev/null
source /usr/share/doc/fzf/examples/key-bindings.bash
# shellcheck source=/dev/null
source /usr/share/bash-completion/completions/fzf
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

alias kas='./kas-container --runtime-args "--net host" --ssh-dir ~/.ssh/'
