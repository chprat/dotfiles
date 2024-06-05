#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

# install packages
xargs sudo apt install -y < "$code_path/packages"

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USERNAME"
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

# install delta
if [ ! -f "$HOME/.local/bin/delta" ]; then
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo delta.tar.gz "https://github.com/dandavison/delta/releases/download/$DELTA_VERSION/delta-$DELTA_VERSION-x86_64-unknown-linux-musl.tar.gz"
    tar xf delta.tar.gz -C "$HOME/.local/bin" "delta-$DELTA_VERSION-x86_64-unknown-linux-musl/delta" --strip-components=1
    rm delta.tar.gz
fi

# install TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    mkdir -p "$HOME/.tmux/plugins/tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# install lazygit
if [ ! -f "$HOME/.local/bin/lazygit" ]; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz -C "$HOME/.local/bin" lazygit
    rm lazygit.tar.gz
fi

# create backup and link dotfiles
for file in gitconfig minirc.dfl tmux.conf vimrc; do
    target_file=".$file"
    if [ ! -L "$HOME/$target_file" ]; then
        if [ -f "$HOME/$target_file" ]; then
            mkdir -p "$code_path/backup"
            mv "$HOME/$target_file" "$code_path/backup/$file"
        fi
        ln -s "$code_path/$file" "$HOME/$target_file"
    fi
done
