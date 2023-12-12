#!/bin/bash

if [ ! -f /.dockerenv ]; then
    docker run --rm --volume "$(pwd):/code:ro" ghcr.io/chprat/linters
    exit
fi

echo "Running shellcheck"
shellcheck ./*.sh

echo "Running editorconfig-checker"
"$HOME/.local/bin/ec" --exclude "\\.git|backup"
