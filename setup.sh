#!/bin/bash -e

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USERNAME"
fi

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"
