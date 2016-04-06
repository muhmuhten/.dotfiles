#!/bin/sh
[ ${1+1} ] || set -- "$PWD/${0##*.}"
for file; do
	[ -f "$file" ] || touch "$file"
	sort -u "$file" "$file.in" "$file.d"/* > "$file.new"
	if cmp -s "$file.new" "$file"; then
		rm "$file.new"
	else
		mv -v "$file.new" "$file"
	fi
done
