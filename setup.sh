#!/bin/bash -e

dir_name=$(dirname "$0")
code_path=$(realpath "$dir_name")

# create ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"

# create ~/.config
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

if [[ -f /etc/os-release ]]; then
    if grep -qi ubuntu /etc/os-release; then
        source "$code_path/ubuntu.sh"
    fi
else
    if [[ $(uname -s) = "Darwin" ]]; then
        source "$code_path/macos.sh"
    fi
fi

# install JetBrainsMono Nerd Font
if [ "$is_desktop" = 1 ]; then
    [ ! -d "$font_dir" ] && mkdir -p "$font_dir"
    if [ ! -f "$font_dir/JetBrainsMonoNerdFontMono-Regular.ttf" ]; then
        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
        unzip -o -j JetBrainsMono.zip "*.ttf" -d "$font_dir"
        rm JetBrainsMono.zip
        fc-cache -f
    fi
fi

# download wallpaper
if [ "$is_desktop" = 1 ]; then
    [ ! -d "$wallpaper_dir" ] && mkdir -p "$wallpaper_dir"
    if [ ! -f "$wallpaper_dir/leafy-moon.png" ]; then
        curl -fsSL https://github.com/rose-pine/wallpapers/raw/refs/heads/main/leafy-moon.png -o "$wallpaper_dir/leafy-moon.png"
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
