#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

delta_release="0.16.5"

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
    curl -LOJR "https://github.com/dandavison/delta/releases/download/$delta_release/delta-$delta_release-x86_64-unknown-linux-musl.tar.gz"
    tar xf "delta-$delta_release-x86_64-unknown-linux-musl.tar.gz" -C "$HOME/.local/bin" "delta-$delta_release-x86_64-unknown-linux-musl/delta" --strip-components=1
    rm "delta-$delta_release-x86_64-unknown-linux-musl.tar.gz"
fi

# create backup and link dotfiles
for file in gitconfig minirc.dfl tmux.conf userhome-hidden vimrc; do
    if [ "$file" = "userhome-hidden" ]; then
        target_file=".hidden"
    elif [ "$file" = "minirc.dfl" ]; then
        target_file="minirc.dfl"
    else
        target_file=".$file"
    fi
    if [ ! -L "$HOME/$target_file" ]; then
        mkdir -p "$code_path/backup"
        mv "$HOME/$target_file" "$code_path/backup/$file"
    fi
    ln -s "$code_path/$file" "$HOME/.$target_file"
done
