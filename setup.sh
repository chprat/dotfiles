#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

delta_release="0.16.5"

# install packages
xargs sudo apt install < "$code_path/packages"

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USERNAME"
fi

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"


# install delta
if [ ! -f "$HOME/.local/bin/delta" ]; then
    curl -LOJR "https://github.com/dandavison/delta/releases/download/$delta_release/delta-$delta_release-x86_64-unknown-linux-musl.tar.gz"
    tar xf "delta-$delta_release-x86_64-unknown-linux-musl.tar.gz" -C "$HOME/.local/bin" "delta-$delta_release-x86_64-unknown-linux-musl/delta" --strip-components=1
    rm "delta-$delta_release-x86_64-unknown-linux-musl.tar.gz"
fi

# create backup and link dotfiles
for file in minirc.dfl userhome-hidden; do
    if [ "$file" = "userhome-hidden" ]; then
        target_file="hidden"
    else
        target_file="$file"
    fi
    if [ ! -L "$HOME/.$target_file" ]; then
        mkdir -p "$code_path/backup"
        mv "$HOME/.$target_file" "$code_path/backup/$target_file"
    fi
    ln -s "$code_path/$file" "$HOME/.$target_file"
done
