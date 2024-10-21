#!/bin/bash -e

# check delta for new version
DELTA_VERSION_NEW=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
DELTA_VERSION_INS=$(grep -Po '^DELTA_VERSION="\K[^"]*' setup.sh)

if [ "$DELTA_VERSION_NEW" != "$DELTA_VERSION_INS" ]; then
    sed -i "/^DELTA_VERSION/s/$DELTA_VERSION_INS/$DELTA_VERSION_NEW/g" setup.sh
    git commit -m "chore: Update delta to $DELTA_VERSION_NEW"
fi

# check lazygit for new version
LAZYGIT_VERSION_NEW=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
LAZYGIT_VERSION_INS=$(grep -Po '^LAZYGIT_VERSION="\K[^"]*' setup.sh)

if [ "$LAZYGIT_VERSION_NEW" != "$LAZYGIT_VERSION_INS" ]; then
    sed -i "/^LAZYGIT_VERSION/s/$LAZYGIT_VERSION_INS/$LAZYGIT_VERSION_NEW/g" setup.sh
    git commit -m "chore: Update lazygit to $LAZYGIT_VERSION_NEW"
fi

# check mdcat for new version
MDCAT_VERSION_NEW=$(curl -s "https://api.github.com/repos/swsnr/mdcat/releases/latest" | grep -Po '"tag_name": "(mdcat-)\K[^"]*')
MDCAT_VERSION_INS=$(grep -Po '^MDCAT_VERSION="\K[^"]*' setup.sh)

if [ "$MDCAT_VERSION_NEW" != "$MDCAT_VERSION_INS" ]; then
    sed -i "/^MDCAT_VERSION/s/$MDCAT_VERSION_INS/$MDCAT_VERSION_NEW/g" setup.sh
    git commit -m "chore: Update mdcat to $MDCAT_VERSION_NEW"
fi
