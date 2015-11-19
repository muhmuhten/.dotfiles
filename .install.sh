#!/bin/sh
set -eu

case $0 in
  */*) cd "${0%/*}"
esac
here=${PWD#$HOME/}

git submodule update --init --depth=1

install() {
  for dot; do
    [ -e "$dot" ] || continue
    file=$here/$dot
    dest=$HOME/.$dot

    case $dot in
      vimstore)
        [ -e "$dest" ] || mkdir -v "$dest"
        install "$dot"/.* "$dot"/*
        ;;
      *) [ -e "$dest" ] || ln -sv "$file" "$dest" ;;
    esac
  done
}

install *
