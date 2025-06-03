#!/bin/bash -e

if [ -n "${BASH_SOURCE[0]}" ]; then
    THIS_SCRIPT=$BASH_SOURCE
elif [ -n "$ZSH_NAME" ]; then
    THIS_SCRIPT=$0
else
    THIS_SCRIPT="$(pwd)/macos.sh"
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

export is_desktop=1
export font_dir="$HOME/Library/Fonts"

if ! command -v brew &>/dev/null; then
    sudo ls &>/dev/null
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >>"$HOME/.zprofile"
    # shellcheck disable=SC2016
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update
brew install "${packages_macos[@]}"
brew install --cask "${packages_desktop_macos[@]}"
