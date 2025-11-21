#!/bin/bash -e

mkdir -p /lazygit/usr/local/bin
mkdir -p /lazygit/DEBIAN

[ ! -d /code/lazygit ] && git clone https://github.com/jesseduffield/lazygit.git /code/lazygit
cd /code/lazygit
git fetch
git checkout "tags/$(git describe --tags --abbrev=0 origin/master)"
go env -w GOBIN=/lazygit/usr/local/bin
go install -ldflags '-s'

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "aarch64" ]; then
    ARCHITECTURE="arm64"
elif [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
fi
VERSION=$(git describe --tags | cut -c2-)
sed "s/{{architecture}}/$ARCHITECTURE/g; s/{{version}}/$VERSION/g" /control.in >/lazygit/DEBIAN/control
mv /lazygit "/lazygit_${ARCHITECTURE}_$VERSION"
dpkg-deb --build "/lazygit_${ARCHITECTURE}_$VERSION"
mv "/lazygit_${ARCHITECTURE}_$VERSION.deb" /out
