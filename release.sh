#!/usr/bin/env nix-shell
#! nix-shell -p bash cargo yq -i bash
# shellcheck shell=bash
#

NEWVERSION="$1"

if [[ $NEWVERSION == "" ]]; then
    echo "No version specified"
    exit 1
fi

echo "Release version: $NEWVERSION"

OLDVERSION=$(tomlq -r ".package.version" Cargo.toml)

sed -i "s|$OLDVERSION|$NEWVERSION|" Cargo.toml

# update lockfile
cargo build

exit
# Commit and tag the update
git add Cargo.toml Cargo.lock
git commit -m "v${VERSION}"
git push origin $(git branch --show-current)
gh release create v${VERSION} -t v${VERSION} -n Pre-release --target $(git branch --show-current) -p

