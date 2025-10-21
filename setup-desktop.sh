#!/bin/bash -e

font_dir="$HOME/.local/share/fonts"
wallpaper_dir="$HOME/.local/share/backgrounds"

packages_desktop_ubuntu=(
    keepassxc
    meld
    nextcloud-desktop
    wezterm
)

# add wezterm repository
if [ ! -f "/etc/apt/keyrings/wezterm-fury.gpg" ]; then
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
fi
if [ ! -f "/etc/apt/sources.list.d/wezterm.list" ]; then
    echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
fi

# install JetBrainsMono Nerd Font
[ ! -d "$font_dir" ] && mkdir -p "$font_dir"
if [ ! -f "$font_dir/JetBrainsMonoNerdFontMono-Regular.ttf" ]; then
    echo "Downloading Nerd Font"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip
    unzip -oqj /tmp/JetBrainsMono.zip "*.ttf" -d "$font_dir"
    rm /tmp/JetBrainsMono.zip
    fc-cache -f
fi

# download wallpaper
[ ! -d "$wallpaper_dir" ] && mkdir -p "$wallpaper_dir"
if [ ! -f "$wallpaper_dir/leafy-moon.png" ]; then
    curl -fsSL https://github.com/rose-pine/wallpapers/raw/refs/heads/main/leafy-moon.png -o "$wallpaper_dir/leafy-moon.png"
fi

sudo apt update && sudo apt install -y "${packages_desktop_ubuntu[@]}"

# Gnome customization
gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper_dir}/leafy-moon.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaper_dir}/leafy-moon.png"
gsettings set org.gnome.nautilus.list-view default-zoom-level "small"
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.shell disabled-extensions "['tiling-assistant@ubuntu.com']"
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.wezfurlong.wezterm.desktop']"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.ding show-home false

# set up kanata
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
