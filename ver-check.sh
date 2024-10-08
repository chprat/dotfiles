#!/bin/bash -e

# check delta for new version
DELTA_VERSION_NEW=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
DELTA_VERSION_INS=$("$HOME/.local/bin/delta" --version | sed -e 's/\x1b\[[0-9;]*m//g' | cut -d' ' -f2)

echo "upstream delta version: $DELTA_VERSION_NEW ($DELTA_VERSION_INS installed)"

# check lazygit for new version
LAZYGIT_VERSION_NEW=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
LAZYGIT_VERSION_INS=$("$HOME/.local/bin/lazygit" --version | sed -e 's/, /\n/g' | grep ^version | cut -d'=' -f2)

echo "upstream lazygit version: $LAZYGIT_VERSION_NEW ($LAZYGIT_VERSION_INS installed)"
