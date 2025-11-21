#!/bin/bash -e

mkdir -p /just/usr/local/bin
mkdir -p /just/DEBIAN

[ ! -d /code/just ] && git clone https://github.com/casey/just.git /code/just
cd /code/just
git fetch
git checkout "tags/$(git describe --tags --abbrev=0 origin/master)"
# shellcheck disable=SC1091
. "$HOME/.cargo/env"
cargo build --release --locked
cp target/release/just /just/usr/local/bin

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi
VERSION=$(git describe --tags)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/just/DEBIAN/control
mv /just "/just_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/just_${ARCHITECTURE}_$VERSION"
mv "/just_${ARCHITECTURE}_$VERSION.deb" /out
