#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

DELTA_VERSION="0.18.1"
LAZYGIT_VERSION="0.44.0"
MDCAT_VERSION="2.4.0"

# install packages
xargs sudo apt install -y < "$code_path/packages"

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USER"
fi

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"

# create ~/.vim/plugged
[ ! -d "$HOME/.vim/plugged" ] && mkdir -p "$HOME/.vim/plugged"

# add source command to ~/.bashrc
if ! grep -q "source $code_path/bashrc" "$HOME/.bashrc"; then
    mkdir -p "$code_path/backup"
    cp "$HOME/.bashrc" "$code_path/backup/bashrc"
    echo "source $code_path/bashrc" >> "$HOME/.bashrc"
fi

# uncomment some lines in ~/.bashrc
sed -i "/bin\/lesspipe/s/^#//" "$HOME/.bashrc"
sed -i "/grep/s/#//" "$HOME/.bashrc"
sed -i "/#alias l/s/^#//" "$HOME/.bashrc"
sed -i "/alias ll/s/^alias ll.*$/alias ll='ls -alFh'/" "$HOME/.bashrc"

# copy ~/.gitconfig.user
if [ ! -f "$HOME/.gitconfig.user" ]; then
    cp "$code_path/gitconfig.user" "$HOME/.gitconfig.user"
    echo "Please update the $HOME/.gitconfig.user configuration!"
fi

# install TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    mkdir -p "$HOME/.tmux/plugins/tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# install delta
function install_delta () {
    curl -Lo delta.tar.gz "https://github.com/dandavison/delta/releases/download/$DELTA_VERSION/delta-$DELTA_VERSION-x86_64-unknown-linux-musl.tar.gz"
    tar xf delta.tar.gz -C "$HOME/.local/bin" "delta-$DELTA_VERSION-x86_64-unknown-linux-musl/delta" --strip-components=1
    rm delta.tar.gz
}
if [ ! -f "$HOME/.local/bin/delta" ]; then
    install_delta
else
    DELTA_VERSION_INS=$("$HOME/.local/bin/delta" --version | sed -e 's/\x1b\[[0-9;]*m//g' | cut -d' ' -f2)
    if [ "$DELTA_VERSION" != "$DELTA_VERSION_INS" ]; then
        install_delta
    fi
fi

# install lazygit
function install_lazygit () {
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz -C "$HOME/.local/bin" lazygit
    rm lazygit.tar.gz
}
if [ ! -f "$HOME/.local/bin/lazygit" ]; then
    install_lazygit
else
    LAZYGIT_VERSION_INS=$("$HOME/.local/bin/lazygit" --version | sed -e 's/, /\n/g' | grep ^version | cut -d'=' -f2)
    if [ "$LAZYGIT_VERSION" != "$LAZYGIT_VERSION_INS" ]; then
        install_lazygit
    fi
fi

# install mdcat
function install_mdcat () {
    curl -Lo mdcat.tar.gz "https://github.com/swsnr/mdcat/releases/latest/download/mdcat-${MDCAT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar xf mdcat.tar.gz --strip-components=1 -C "$HOME/.local/bin" "mdcat-${MDCAT_VERSION}-x86_64-unknown-linux-musl/mdcat"
    rm mdcat.tar.gz
}
if [ ! -f "$HOME/.local/bin/mdcat" ]; then
    install_mdcat
    ln -s "$HOME/.local/bin/mdcat" "$HOME/.local/bin/mdless"
else
    MDCAT_VERSION_INS=$("$HOME/.local/bin/mdcat" --version | head -n1 | cut -d' ' -f2)
    if [ "$MDCAT_VERSION" != "$MDCAT_VERSION_INS" ]; then
        install_mdcat
    fi
fi

# create backup and link dotfiles
for file in gitconfig minirc.dfl tmux.conf vimrc wezterm.lua; do
    target_file=".$file"
    if [ ! -L "$HOME/$target_file" ]; then
        if [ -f "$HOME/$target_file" ]; then
            mkdir -p "$code_path/backup"
            mv "$HOME/$target_file" "$code_path/backup/$file"
        fi
        ln -s "$code_path/$file" "$HOME/$target_file"
    fi
done

# disable dmesg access restrictions
if  [ "$(sysctl -n kernel.dmesg_restrict)" = "1" ]; then
    echo "kernel.dmesg_restrict = 0" | sudo tee /etc/sysctl.d/10-dmesg-access.conf
fi

# add wezterm repository
if [ ! -f "/etc/apt/keyrings/wezterm-fury.gpg" ]; then
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
fi
if [ ! -f "/etc/apt/sources.list.d/wezterm.list" ]; then
    echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update
fi
