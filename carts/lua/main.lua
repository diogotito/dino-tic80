-- title:   Dinolode
-- author:  mimi, pati, tito, tomi
-- desc:    motherlode but with dinosaurs
-- site:    https://diogotito.com/experiments/dinoscene
-- license: CC0-1.0
-- version: 0.1
-- script:  lua

include "Vector2"

function TIC()
    cls(7)
    local vec = v2(10) + v2(100)
    print("hi", vec.x, vec.y, 5)
end