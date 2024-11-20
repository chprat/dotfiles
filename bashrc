# easier navigation
# shellcheck shell=bash
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# add ~/.local/bin to PATH
PATH="$PATH":"$HOME"/.local/bin

# set default editor
EDITOR=$(which vim)
export EDITOR

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
    if ! sudo apt update; then
        return
    fi
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    dpkg -l |grep ^rc | awk '{ print $2 }' | xargs sudo apt purge -y
    if which snap > /dev/null; then
        sudo snap refresh
    fi
}

# backup files with rclone
function backup () {
    cp "$HOME/.ssh/config" "$HOME/data/ssh-config"
    rclone sync "$HOME/data/" "nc:staging/$HOSTNAME/"
}

# Yocto directory exports FAG
function fagexports () {
    export DL_DIR=/var/yocto/fag/kirkstone-downloads-cache
    export SSTATE_DIR=/var/yocto/fag/kirkstone-sstate-cache
    export CCACHE_DIR=/var/yocto/fag/ccache
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

# extract IPKs
function exIPK () {
    for i in *.ipk; do
        FOLDER_NAME="$(echo "$i" | awk -F_ '{ print $1 }')"
        mkdir "$FOLDER_NAME"
        ar x "$i" --output "$FOLDER_NAME" data.tar.xz
        tar xf "$FOLDER_NAME/data.tar.xz" -C "$FOLDER_NAME"
        rm "$FOLDER_NAME/data.tar.xz"
        rm "$i"
    done
}

# enable autojump
# shellcheck source=/dev/null
[[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh || printf "\nCould not find autojump integration"

# enable fzf
eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

alias kas='./kas-container --runtime-args "--net host -v $CCACHE_DIR:/ccache" --ssh-dir ~/.ssh/'
alias qtcreator='QT_QPA_PLATFORM=wayland /opt/Qt/Tools/QtCreator/bin/qtcreator &'

alias prepare-nfs-fgw='./scripts/deploy-image.sh -n -N /srv/nfs-fgw -r fwk-rpi -T -'
alias prepare-nfs-mesa-mmi='./scripts/deploy-image.sh -n -N /srv/nfs-mesa-mmi -r fwk-rpi -T -'
alias prepare-nfs-con='./scripts/deploy-image.sh -n -N /srv/nfs-con -r fwk-rpi -T -'

alias g='git'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gst='git status'

# build all kas configurations
function kas-build-all () {
    fagexports
    for config in *.yml; do
        echo ""
        echo "Downloading $config"
        [ -f "$config" ] && kas build "$config":.kas/local.yaml -- --runall=fetch || return
    done
    for config in *.yml; do
        echo ""
        echo "Building $config"
        kas clean
        [ -f "$config" ] && kas build "$config":.kas/local.yaml -- -k || return
    done
}

# enable starship
eval "$(starship init bash)"

# enable direnv
eval "$(direnv hook bash)"
