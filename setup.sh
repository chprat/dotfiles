#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

packages_ubuntu=(
    bat
    build-essential
    cmake
    curl
    direnv
    eza
    fd-find
    fzf
    git
    git-delta
    npm
    podman
    python3-venv
    rclone
    ripgrep
    rsync
    stow
    tealdeer
    tio
    tmux
    vim
    zoxide
    zsh
)
#    luarocks

# install packages
sudo apt update
sudo apt install -y "${packages_ubuntu[@]}"

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USER"
fi

# disable dmesg access restrictions
if [ "$(sysctl -n kernel.dmesg_restrict)" = "1" ]; then
    echo "kernel.dmesg_restrict = 0" | sudo tee /etc/sysctl.d/10-dmesg-access.conf
fi

# switch user shell to zsh
USRSHELL=$(grep "^$USER:" /etc/passwd | cut -f7 -d':' | rev | cut -f1 -d'/' | rev)
if [ -n "$USRSHELL" ] && [ "$USRSHELL" != "zsh" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
    echo -e "\033[0;31mZSH will be enabled after rebooting.\033[0m"
fi

# create backup and link dotfiles
stow .

# copy git config.user
if [ ! -f "$HOME/.config/git/config.user" ]; then
    cp "$code_path/git/config.user.example" "$HOME/.config/git/config.user"
    echo -e "\033[0;31mPlease update the $HOME/.config/git/config.user configuration!\033[0m"
fi

# install TPM
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
    mkdir -p "$HOME/.config/tmux/plugins/tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

# install tmux plugins
if [ ! -d "$HOME/.tmux/plugins/tmux" ]; then
    tmux start-server
    tmux new-session -d
    "$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null
    tmux kill-server
fi

# continue with desktop setup
if dpkg -l "*ubuntu-desktop*" >/dev/null 2>&1; then
    ./setup-desktop.sh
fi
