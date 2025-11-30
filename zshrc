if [[ $(uname -s) = "Darwin" ]]; then
    autoload -U compinit && compinit
fi

# setup zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
# shellcheck source=/dev/null
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found

# update compdefs
zinit cdreplay -q

if [ ! -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/plugins/Aloxaf---fzf-tab/modules/zsh" ]; then
    build-fzf-tab-module
fi

# History
HISTDUP=erase
export HISTDUP
HISTFILE=~/.zsh_history
export HISTFILE
HISTSIZE=5000
export HISTSIZE
SAVEHIST=$HISTSIZE
export SAVEHIST
setopt appendhistory
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt sharehistory

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # match lower- and uppercase

# shellcheck disable=SC2296
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"            # complete with colors
zstyle ':completion:*' menu no                                     # disable default menu, we use fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'                  # enable group support
zstyle ':completion:*:git-checkout:*' sort false                   # no sort on `git checkout`
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept # custom fzf flags
zstyle ':fzf-tab:*' switch-group '<' '>'                           # switch group using `<` and `>`
if command -v eza &>/dev/null; then
    # shellcheck disable=SC2016
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    if command -v zoxide &>/dev/null; then
        # shellcheck disable=SC2016
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
        # shellcheck disable=SC2016
        zstyle ':fzf-tab:complete:zoxide:*' fzf-preview 'eza -1 --color=always $realpath'
    fi
fi

# Keybindings
bindkey -e                           # emacs mode
bindkey '^p' history-search-backward # complete only with prefix
bindkey '^n' history-search-forward  # complete only with prefix

# Variables
EDITOR=$(which nvim)
export EDITOR
PATH="$PATH":"$HOME"/.local/bin
export PATH

if command -v rg &>/dev/null; then
    RIPGREP_CONFIG_PATH="$HOME"/.config/ripgreprc
    export RIPGREP_CONFIG_PATH
fi

# Aliases
if command -v eza &>/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -al --icons=always --smart-group --group-directories-first'
fi

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

if ! command -v fd &>/dev/null; then
    alias fd='fdfind'
fi

# Shell integrations

# enable bat(cat)
if command -v batcat &>/dev/null; then
    BAT_STYLE="auto"
    export BAT_STYLE
    BAT_THEME="Solarized (light)"
    export BAT_THEME
    alias cat="batcat"
fi

# enable direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

if command -v fzf &>/dev/null; then
    # colors are rose-pine-moon
    export FZF_DEFAULT_OPTS='--tmux --height 40% --reverse --border
        --color=fg:#908caa,bg:#232136,hl:#ea9a97
        --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
        --color=border:#44415a,header:#3e8fb0,gutter:#232136
        --color=spinner:#f6c177,info:#9ccfd8
        --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa'
    if command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
        export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git"
    elif command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
        export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
    fi
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    if command -v batcat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always --line-range :500 {}'"
    fi

    if command -v eza &>/dev/null; then
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
    fi

    if command -v fdfind &>/dev/null; then
        _fzf_compgen_path() {
            fdfind --hidden --exclude .git . "$1"
        }

        _fzf_compgen_dir() {
            fdfind --type=d --hidden --exclude .git . "$1"
        }
    elif command -v fd &>/dev/null; then
        _fzf_compgen_path() {
            fd --hidden --exclude .git . "$1"
        }

        _fzf_compgen_dir() {
            fd --type=d --hidden --exclude .git . "$1"
        }
    fi

    if command -v batcat &>/dev/null; then
        if command -v eza &>/dev/null; then
            show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else batcat -n --color=always --line-range :500 {}; fi"
            export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
            _fzf_comprun() {
                local command=$1
                shift

                case "$command" in
                cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
                export | unset) fzf --preview "eval 'echo $'{}" "$@" ;;
                ssh) fzf --preview 'dig {}' "$@" ;;
                *) fzf --preview "batcat -n --color=always --line-range :500 {}" "$@" ;;
                esac
            }
        fi
    fi
    eval "$(fzf --zsh)"
fi

# enable just
if command -v just &>/dev/null; then
    eval "$(just --completions zsh)"
    alias j="just"
fi

# enable pet
if command -v pet &>/dev/null; then
    eval "$(pet completion zsh)"
fi

# enable starship
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# enable zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Functions

# backup files with rclone
function backup() {
    cp "$HOME/.ssh/config" "$HOME/data/ssh-config"
    rclone sync "$HOME/data/" "nc:staging/$HOST/"
}

# cd .. multiple times
function cdn() {
    for _i in $(seq "$1"); do
        cd ..
    done
}

# extract IPKs
function exIPK() {
    for i in *.ipk; do
        FOLDER_NAME="$(echo "$i" | awk -F_ '{ print $1 }')"
        mkdir "$FOLDER_NAME"
        ar x "$i" --output "$FOLDER_NAME" data.tar.xz
        tar xf "$FOLDER_NAME/data.tar.xz" -C "$FOLDER_NAME"
        rm "$FOLDER_NAME/data.tar.xz"
        rm "$i"
    done
}

# extract Yocto rootfs archive
function exRFS() {
    rm -rf rootfs
    mkdir rootfs
    tar xf "$(find build/tmp**/deploy/images/ -iname '*rootfs.tar.gz')" -C rootfs
}

# create folder and cd into
function mcd() {
    mkdir -p "$1" && cd "$1" || return
}

# remove empty directories
function rme() {
    find . -type d -empty -print -delete
}

# update system
function sysupgr() {
    if ! sudo apt update; then
        return
    fi
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    dpkg -l | grep ^rc | awk '{ print $2 }' | xargs sudo apt purge -y
    if which snap >/dev/null; then
        sudo snap refresh
    fi
}
