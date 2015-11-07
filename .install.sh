#!/bin/sh
set -e

case $0 in
  */*) cd "${0%/*}"
esac
here=${PWD#$HOME/}

git submodule update --init --depth=1

for dot in *; do
  file=$HOME/.$dot
  dest=$here/$dot
  [ -e "$file" ] || ln -sv "$dest" "$file"
done
