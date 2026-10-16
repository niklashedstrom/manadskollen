#!/bin/sh
# Stamp a new build id into index.html and version.txt, so open Home Screen apps reload themselves.
set -e
id=$(date -u +%Y%m%d%H%M%S)
sed -i -E "s/const BUILD=\"[^\"]*\"/const BUILD=\"$id\"/" index.html
printf '%s\n' "$id" > version.txt
echo "$id"
