#!/bin/bash -e

if which podman &> /dev/null; then
    CONTAINER_CMD="podman"
    CONTAINER_CHECK_FILE="/run/.containerenv"
elif which docker &> /dev/null; then
    CONTAINER_CMD="docker"
    CONTAINER_CHECK_FILE="/.dockerenv"
fi

if [ -n "$CONTAINER_CHECK_FILE" ] && [ ! -f "$CONTAINER_CHECK_FILE" ]; then
    $CONTAINER_CMD build -t dotfile-linter -f Containerfile .
    $CONTAINER_CMD run --rm --volume "$(pwd):/code:ro" -w /code dotfile-linter /code/lint.sh
    exit
fi

echo "Running shellcheck"
shellcheck ./*.sh

echo "Running editorconfig-checker"
# shellcheck disable=SC1091
. "$HOME/linter-venv/bin/activate"
ec --exclude "\\.git|backup"

echo "Running hadolint"
"$HOME/hadolint" Containerfile
