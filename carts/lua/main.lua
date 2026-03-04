-- title:   Dinolode
-- author:  mimi, pati, tito, tomi
-- desc:    motherlode but with dinosaurs
-- site:    https://diogotito.com/experiments/dinoscene
-- license: CC0-1.0
-- version: 0.1
-- script:  lua

include "tic80-lua-utils"
include "Vector2"

include "game_constants"
include "terrain_grid"
include "Cam"


function BOOT()
    terrain_generate()
end


function TIC()
    Cam:move_with_input()
    local x, y, sx, sy = Cam:map_params()

    cls()
    map(x, y, ROOM_WIDTH + 1, ROOM_HEIGHT + 1, sx, sy)
end
