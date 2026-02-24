#!/bin/sh

# Set $dir to this script's directory
# Source - https://stackoverflow.com/a/29835459
# Posted by mklement0, modified by community. See post 'Timeline' for change history
# Retrieved 2026-02-22, License - CC BY-SA 4.0
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

cd "${dir}/carts"
exec "${dir}/bin/tic80" --fs="$(pwd)" --cmd="load dinolode.lua"
