#!/bin/sh

dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${dir}/bin"

cd "${dir}/carts" || exit
exec "${dir}/bin/tq-bundler" run dinolode.lua lua/main.lua --tic "${dir}/bin/tic80"
