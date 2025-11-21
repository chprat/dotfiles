#!/bin/bash -e

mkdir -p /starship/usr/local/bin
mkdir -p /starship/DEBIAN

[ ! -d /code/starship ] && git clone https://github.com/starship/starship.git /code/starship
cd /code/starship
git fetch
git checkout "tags/$(git describe --tags --abbrev=0 origin/master)"
# shellcheck disable=SC1091
. "$HOME/.cargo/env"
cargo build --release --locked
cp target/release/starship /starship/usr/local/bin

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi
VERSION=$(git describe --tags --exclude shipped | cut -c2-)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/starship/DEBIAN/control
mv /starship "/starship_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/starship_${ARCHITECTURE}_$VERSION"
mv "/starship_${ARCHITECTURE}_$VERSION.deb" /out
