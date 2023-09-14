#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

# install packages
xargs sudo apt install < "$code_path/packages"

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USERNAME"
fi

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"

# create backup and link dotfiles
for file in minirc.dfl; do
    target_file="$file"
    if [ ! -L "$HOME/.$target_file" ]; then
        mkdir -p "$code_path/backup"
        mv "$HOME/.$target_file" "$code_path/backup/$target_file"
    fi
    ln -s "$code_path/$file" "$HOME/.$target_file"
done
