#!/bin/bash -e

mkdir -p /neovim/usr/local
mkdir -p /neovim/DEBIAN

[ ! -d /code/neovim ] && git clone https://github.com/neovim/neovim /code/neovim
cd /code/neovim
git fetch
git checkout "tags/$(git tag | sort -V | tail -1)"
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/neovim/usr/local install

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi
VERSION=$(git describe --tags --exclude stable --exclude nightly | cut -c2-)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/neovim/DEBIAN/control
mv /neovim "/neovim_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/neovim_${ARCHITECTURE}_$VERSION"
mv "/neovim_${ARCHITECTURE}_$VERSION.deb" /out
