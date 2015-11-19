#!/bin/sh
set -eu

case $0 in
  */*) cd "${0%/*}"
esac
here=${PWD#$HOME/}

git submodule update --init --depth=1

install_files() {
  for dot; do
    [ -e "$dot" ] || continue
    file=${here}/$dot
    dest=$HOME/.$dot

    case $dot in
      s6|vimstore)
        [ -e "$dest" ] || mkdir -v "$dest"
        (here=../$here install_files "$dot"/.* "$dot"/*)
        ;;
      *) [ -e "$dest" ] || ln -sv "$file" "$dest" ;;
    esac
  done
}

install_files *
