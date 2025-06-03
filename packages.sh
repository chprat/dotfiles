#!/bin/bash -e

if [ -n "${BASH_SOURCE[0]}" ]; then
    THIS_SCRIPT=$BASH_SOURCE
elif [ -n "$ZSH_NAME" ]; then
    THIS_SCRIPT=$0
else
    THIS_SCRIPT="$(pwd)/packages.sh"
    if [ ! -e "$THIS_SCRIPT" ]; then
        echo "Error: $THIS_SCRIPT doesn't exist!" >&2
        exit 1
    fi
fi
if [ -z "$ZSH_NAME" ] && [ "$0" = "$THIS_SCRIPT" ]; then
    echo "Error: This script needs to be sourced. Please run as '. $THIS_SCRIPT'" >&2
    exit 1
fi

export packages_ubuntu=(
    bat
    curl
    direnv
    fd-find
    git
    luarocks
    make
    mc
    npm
    python3-venv
    rclone
    ripgrep
    rsync
    stow
    tealdeer
    tio
    tmux
    zoxide
    zsh
)

export snaps_ubuntu_classic=(
    cmake
    just
    nvim
)

export packages_desktop_ubuntu=(
    keepassxc
    meld
    nextcloud-desktop
    wezterm
)

export packages_macos=(
    act
    autoconf
    bat
    direnv
    eza
    fd
    fonconfig
    fzf
    git-delta
    just
    lazygit
    neovim
    ripgrep
    starship
    stow
    tealdeer
    tmux
    yazi
    zoxide
)

export packages_desktop_macos=(
    wezterm
)
