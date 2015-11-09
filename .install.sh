#!/bin/sh
set -e

case $0 in
  */*) cd "${0%/*}"
esac
here=${PWD#$HOME/}

git submodule update --init --depth=1

for dot in *; do
  file=$here/$dot
  dest=$HOME/.$dot

  [ -e "$dest" ] && continue
  case $dot in
    vimstore) mkdir -v "$dest" ;;
    *) ln -sv "$file" "$dest" ;;
  esac
done
