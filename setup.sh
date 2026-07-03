#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

packages_ubuntu=(
    bat
    cmake
    curl
    direnv
    eza
    fd-find
    git
    git-delta
    luarocks
    make
    npm
    python3-venv
    ripgrep
    rsync
    stow
    tio
    tmux
    zoxide
    zsh
)

snaps_ubuntu_classic=(
    just
)

packages_desktop_ubuntu=(
    gnome-shell-extensions
    keepassxc
    meld
    nextcloud-desktop
    wezterm-nightly
    wl-clipboard
)

gnome_extensions=(
    caffeine@patapon.info
    Resource_Monitor@Ory0n
)

is_desktop=$(
    if dpkg -l "ubuntu-desktop*" >/dev/null 2>&1; then
        echo 1
    else
        echo 0
    fi
)

font_dir="$HOME/.local/share/fonts"
wallpaper_dir="$HOME/.local/share/backgrounds"

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"

# create ~/.config
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

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

# disable global compinit from /etc/zsh/zshrc
if [ ! -f "$HOME/.zshenv" ]; then
    echo "skip_global_compinit=1" >>"$HOME/.zshenv"
fi

# Gnome customization
if [ "$is_desktop" = 1 ]; then
    CHROME_DESKTOP=""
    if [ -f /opt/google/chrome/chrome ]; then
        CHROME_DESKTOP="'google-chrome.desktop',"
    fi
    FAV_APPS="['firefox_firefox.desktop', $CHROME_DESKTOP 'org.wezfurlong.wezterm.desktop']"
    gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper_dir}/leafy-moon.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaper_dir}/leafy-moon.png"
    gsettings set org.gnome.desktop.sound event-sounds false
    gsettings set org.gnome.nautilus.list-view default-zoom-level "small"
    gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.shell disabled-extensions "['tiling-assistant@ubuntu.com']"
    gsettings set org.gnome.shell favorite-apps "$FAV_APPS"
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "BOTTOM"
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.ding show-home false
fi

# Gnome extensions
if [ "$is_desktop" = 1 ]; then
    python3 -m venv --upgrade-deps .venv >/dev/null
    .venv/bin/python3 -m pip install gnome-extensions-cli >/dev/null

    for ext in "${gnome_extensions[@]}"; do
        if ! .venv/bin/gext list | grep "$ext" &>/dev/null; then
            echo "Installing extension: $ext"
            .venv/bin/gext install "$ext" >/dev/null
            if [[ $ext =~ "caffeine" ]]; then
                if [ ! -f "$HOME/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/gschemas.compiled" ]; then
                    glib-compile-schemas "$HOME/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/"
                fi
            fi
        fi
    done

    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor diskspacestatus false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor diskstatsstatus false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor netethstatus false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor netwlanstatus false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor ramunit "perc"
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/Resource_Monitor@Ory0n/schemas set org.gnome.shell.extensions.resource-monitor thermalcputemperaturestatus true

    rm -r .venv
fi

# install JetBrainsMono Nerd Font
if [ "$is_desktop" = 1 ]; then
    [ ! -d "$font_dir" ] && mkdir -p "$font_dir"
    if [ ! -f "$font_dir/JetBrainsMonoNerdFontMono-Regular.ttf" ]; then
        echo "Downloading Nerd Font"
        curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip
        unzip -oqj /tmp/JetBrainsMono.zip "*.ttf" -d "$font_dir"
        rm /tmp/JetBrainsMono.zip
        fc-cache -f
    fi
fi

# download wallpaper
if [ "$is_desktop" = 1 ]; then
    [ ! -d "$wallpaper_dir" ] && mkdir -p "$wallpaper_dir"
    if [ ! -f "$wallpaper_dir/leafy-moon.png" ]; then
        curl -fsSL https://github.com/rose-pine/wallpapers/raw/refs/heads/main/illustration/leafy-moon.png -o "$wallpaper_dir/leafy-moon.png"
    fi
fi

# link a file and backup the original
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
stow .
link_file "zshrc" "$HOME/.zshrc"

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

# install rust
if [ ! -d "$HOME/.cargo" ]; then
    curl -fsSl https://sh.rustup.rs | sh -s -- --no-modify-path -y
fi

# install rust-analyzer
if [ ! -f "$HOME/.cargo/bin/rust-analyzer" ]; then
    "$HOME/.cargo/bin/rustup" component add rust-analyzer
fi

# install cargo-binstall
if [ ! -f "$HOME/.cargo/bin/cargo-binstall" ]; then
    "$HOME/.cargo/bin/cargo" install cargo-binstall
    link_file binstall.toml "$HOME/.cargo"
fi

# install cargo-update
if [ ! -f "$HOME/.cargo/bin/cargo-install-update" ]; then
    "$HOME/.cargo/bin/cargo" binstall cargo-update
fi

# install tldr
if [ ! -f "$HOME/.cargo/bin/tldr" ]; then
    "$HOME/.cargo/bin/cargo" binstall tealdeer
fi

# install uv
if [ ! -f "$HOME/.cargo/bin/uv" ]; then
    "$HOME/.cargo/bin/cargo" binstall uv
fi

# install yazi
if [ ! -f "$HOME/.cargo/bin/yazi" ]; then
    "$HOME/.cargo/bin/cargo" binstall yazi-fm
fi

# install kanata
if [ ! -f "$HOME/.cargo/bin/kanata" ]; then
    "$HOME/.cargo/bin/cargo" binstall kanata
fi

# install mise
if [ ! -f "$HOME/.cargo/bin/mise" ]; then
    "$HOME/.cargo/bin/cargo" binstall mise
    "$HOME/.cargo/bin/mise" trust mise/config.toml
fi

# install globally managed mise tools
"$HOME/.cargo/bin/mise" install
