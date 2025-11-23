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
    git-delta
    luarocks
    make
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
    gnome-shell-extensions
    keepassxc
    meld
    nextcloud-desktop
    wezterm
    wl-clipboard
)

export gnome_extensions=(
    caffeine@patapon.info
    Resource_Monitor@Ory0n
)

export packages_macos=(
    autoconf
    bat
    direnv
    eza
    fd
    fontconfig
    fzf
    git-delta
    gnu-sed
    just
    lazygit
    luarocks
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
