SET "GAME=carts/dinolode.lua"
SET "CODE=carts/lua/main.lua"
SET "OUT=build/build.lua"

bin\tq-bundler.exe^
 run^
 --tic bin/tic80.exe^
 --output %OUT%^
 %GAME% %CODE%
