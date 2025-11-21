#!/bin/bash -e

if [ -n "${BASH_SOURCE[0]}" ]; then
    THIS_SCRIPT=$BASH_SOURCE
elif [ -n "$ZSH_NAME" ]; then
    THIS_SCRIPT=$0
else
    THIS_SCRIPT="$(pwd)/ubuntu.sh"
    if [ ! -e "$THIS_SCRIPT" ]; then
        echo "Error: $THIS_SCRIPT doesn't exist!" >&2
        exit 1
    fi
fi
if [ -z "$ZSH_NAME" ] && [ "$0" = "$THIS_SCRIPT" ]; then
    echo "Error: This script needs to be sourced. Please run as '. $THIS_SCRIPT'" >&2
    exit 1
fi

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

source "$code_path/packages.sh"

is_desktop=$(
    if dpkg -l "ubuntu-desktop*" >/dev/null 2>&1; then
        echo 1
    else
        echo 0
    fi
)

export font_dir="$HOME/.local/share/fonts"
export wallpaper_dir="$HOME/.local/share/backgrounds"

# add wezterm repository
if [ "$is_desktop" = 1 ]; then
    if [ ! -f "/etc/apt/keyrings/wezterm-fury.gpg" ]; then
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
    fi
    if [ ! -f "/etc/apt/sources.list.d/wezterm.list" ]; then
        echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    fi
fi

# install packages
sudo apt update
sudo apt install -y "${packages_ubuntu[@]}"
if command -v snap &>/dev/null; then
    for snap in "${snaps_ubuntu_classic[@]}"; do
        if ! snap list | grep -q "^$snap"; then
            sudo snap install --classic "${snap}"
        fi
    done
fi
if [ "$is_desktop" = 1 ]; then
    sudo apt install -y "${packages_desktop_ubuntu[@]}"
fi

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

# install github packages
./ghpkg.py download

# install fzf-tmux wrapper script
if [ ! -f "$HOME/.local/bin/fzf-tmux" ]; then
    curl -LO https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/bin/fzf-tmux
    chmod +x fzf-tmux
    mv fzf-tmux "$HOME/.local/bin/"
fi

# set up kanata
if [ "$is_desktop" = 1 ]; then
    if ! getent group input >/dev/null 2>&1; then
        sudo groupadd input
    fi

    if ! getent group uinput >/dev/null 2>&1; then
        sudo groupadd uinput
    fi

    if ! groups | grep -q input; then
        sudo usermod -aG input "$USER"
    fi

    if ! groups | grep -q uinput; then
        sudo usermod -aG uinput "$USER"
    fi

    if [ ! -f /etc/udev/rules.d/99-input.rules ]; then
        echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules
        sudo udevadm control --reload-rules
        sudo udevadm trigger
    fi

    if [ ! -f /etc/modules-load.d/kanata.conf ]; then
        echo 'uinput' | sudo tee /etc/modules-load.d/kanata.conf
    fi

    if [ ! -f "$HOME"/.config/systemd/user/kanata.service ]; then
        mkdir -p "$HOME"/.config/systemd/user/
        sed s,@@HOME@@,"$HOME",g kanata.service.in >"$HOME"/.config/systemd/user/kanata.service
        systemctl --user daemon-reload
        systemctl --user enable kanata.service
        systemctl --user start kanata.service
    fi
fi
