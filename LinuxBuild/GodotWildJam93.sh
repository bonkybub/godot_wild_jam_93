#!/bin/sh
printf '\033c\033]0;%s\a' GodotWildJam93
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GodotWildJam93.x86_64" "$@"
