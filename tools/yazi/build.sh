#!/bin/bash -e

mkdir -p /yazi/usr/local/bin
mkdir -p /yazi/DEBIAN

[ ! -d /code/yazi ] && git clone https://github.com/sxyazi/yazi.git /code/yazi
cd /code/yazi
git fetch
git checkout "tags/$(git describe --tags --exclude shipped --exclude nightly --abbrev=0 origin/main)"
# shellcheck disable=SC1091
. "$HOME/.cargo/env"
cargo build --release --locked
cp target/release/ya target/release/yazi /yazi/usr/local/bin

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi
VERSION=$(git describe --tags --exclude shipped --exclude nightly | cut -c2-)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/yazi/DEBIAN/control
mv /yazi "/yazi_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/yazi_${ARCHITECTURE}_$VERSION"
mv "/yazi_${ARCHITECTURE}_$VERSION.deb" /out
