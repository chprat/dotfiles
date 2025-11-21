#!/bin/bash -e

mkdir -p /kanata/usr/local/bin
mkdir -p /kanata/DEBIAN

[ ! -d /code/kanata ] && git clone https://github.com/jtroo/kanata.git /code/kanata
cd /code/kanata
git fetch
# shellcheck disable=2035 # we do not operate on files
git checkout "tags/$(git describe --tags --exclude *prerelease* --abbrev=0 origin/main)"
# shellcheck disable=SC1091 # the file might not be available here, do not follow
. "$HOME/.cargo/env"
cargo build --release --locked
cp target/release/kanata /kanata/usr/local/bin

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi

# shellcheck disable=2035 # we do not operate on files
VERSION=$(git describe --tags --exclude *prerelease* | cut -c2-)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/kanata/DEBIAN/control
mv /kanata "/kanata_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/kanata_${ARCHITECTURE}_$VERSION"
mv "/kanata_${ARCHITECTURE}_$VERSION.deb" /out
