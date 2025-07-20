#!/bin/sh
echo -ne '\033c\033]0;GodotWildJam7-25\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GodotWildJam7-25.x86_64" "$@"
