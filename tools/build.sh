#!/bin/bash -e

[ ! -d deb ] && mkdir deb

if which podman &>/dev/null; then
    CONTAINER_CMD="podman"
    SPECIAL_OPTS="--format docker"
elif which docker &>/dev/null; then
    CONTAINER_CMD="docker"
fi

# shellcheck disable=SC2086
$CONTAINER_CMD pull ubuntu:24.04

SUPPORTED_TOOLS=(just kanata lazygit neovim starship yazi)
build_tool() {
    if [[ ! ${SUPPORTED_TOOLS[*]} =~ $TOOL ]]; then
        echo "tool $TOOL is not supported"
        return
    fi
    FRAMEWORK="rust"
    if [ "$TOOL" == "neovim" ]; then
        FRAMEWORK="neovim"
    elif [ "$TOOL" == "lazygit" ]; then
        FRAMEWORK="golang"
    fi
    # shellcheck disable=SC2086
    $CONTAINER_CMD build $SPECIAL_OPTS -t $TOOL-builder -f Containerfile.$FRAMEWORK $TOOL
    $CONTAINER_CMD run --rm \
        --volume "tools-code:/code" \
        --volume "$(pwd)/deb:/out" \
        "$TOOL-builder" /build.sh
}

if [ "$#" -eq 0 ]; then
    for TOOL in "${SUPPORTED_TOOLS[@]}"; do
        build_tool
    done
elif [ "$#" -eq 1 ]; then
    TOOL=$1
    build_tool
else
    echo "too many arguments"
fi
