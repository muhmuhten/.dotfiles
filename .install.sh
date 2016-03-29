#!/bin/sh
set -eu

case $0 in
  */*) cd "${0%/*}"
esac
here=${PWD#$HOME/}

git submodule update --init

install_files() {
  for dot; do
    [ -e "$dot" ] || continue
    file=${here}/$dot
    dest=$HOME/.$dot

    case $dot in
      bin|s6|vimstore|*.d)
        [ -e "$dest" ] || mkdir -v "$dest"
        (here=../$here install_files "$dot"/.* "$dot"/*)
        ;;
      *) [ -e "$dest" ] || ln -sv "$file" "$dest" ;;
    esac
  done
}

install_files *
