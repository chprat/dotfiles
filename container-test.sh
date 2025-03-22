#!/bin/bash -e

IMAGE_NAME=dotfiles-test
IMAGE_VARIANT=cli
if [ "$1" = desktop ]; then
    IMAGE_VARIANT=desktop
fi

MOUNT_DIR=/home/ubuntu/.dotfiles

docker build --target ${IMAGE_VARIANT} -t ${IMAGE_NAME}-${IMAGE_VARIANT} .
docker run --rm -it -v "$PWD":${MOUNT_DIR} -w ${MOUNT_DIR} -e USER=tester ${IMAGE_NAME}-${IMAGE_VARIANT}
