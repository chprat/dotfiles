#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

# install packages
xargs sudo apt install -y <"$code_path/packages"
if dpkg -l "ubuntu-desktop*" >/dev/null; then
    xargs sudo apt install -y <"$code_path/packages-desktop"
fi

# add user to dialout
if ! groups | grep -q dialout; then
    sudo usermod -aG dialout "$USER"
fi

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"

# create ~/.vim/plugged
[ ! -d "$HOME/.vim/plugged" ] && mkdir -p "$HOME/.vim/plugged"

# create ~/.config
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

# add source command to ~/.bashrc
if ! grep -q "source $code_path/bashrc" "$HOME/.bashrc"; then
    mkdir -p "$code_path/backup"
    cp "$HOME/.bashrc" "$code_path/backup/bashrc"
    echo "source $code_path/bashrc" >>"$HOME/.bashrc"
fi

# uncomment some lines in ~/.bashrc
sed -i "/bin\/lesspipe/s/^#//" "$HOME/.bashrc"
sed -i "/grep/s/#//" "$HOME/.bashrc"

# copy ~/.gitconfig.user
if [ ! -f "$HOME/.gitconfig.user" ]; then
    cp "$code_path/gitconfig.user" "$HOME/.gitconfig.user"
    echo -e "\033[0;31mPlease update the $HOME/.gitconfig.user configuration!\033[0m"
fi

# install TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    mkdir -p "$HOME/.tmux/plugins/tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# disable dmesg access restrictions
if [ "$(sysctl -n kernel.dmesg_restrict)" = "1" ]; then
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

# install github packages
./ghpkg.py download

function link_file() {
    file="$1"
    dest="$2"
    src="$code_path/$file"
    if [ ! -L "$dest" ]; then
        if [ -f "$dest" ]; then
            mkdir -p "$code_path/backup"
            mv "$dest" "$code_path/backup/$file"
        fi
        ln -s "$src" "$dest"
    fi
}

# create backup and link dotfiles
for file in gitconfig minirc.dfl tmux.conf vimrc wezterm.lua; do
    target_file=".$file"
    link_file "$file" "$HOME/$target_file"
done
link_file "nvim" "$HOME/.config/nvim"
link_file "starship.toml" "$HOME/.config/starship.toml"
