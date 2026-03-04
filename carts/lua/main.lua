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
include "player"
include "Cam"


function BOOT()
    terrain_generate()
end


function TIC()
    player:update()
    Cam:look_at(player.pos.x, player.pos.y):enforce_bounds()

    local x, y, sx, sy = Cam:map_params()

    cls()
    map(x, y, ROOM_WIDTH + 1, ROOM_HEIGHT + 1, sx, sy)
    player:draw()
    print(("Cam @ (%5.2f, %5.2f)"):format(Cam.x, Cam.y), 10, 10)
    print(("x,y = (%5.2f, %5.2f)"):format(x, y), 10, 20)
    print(("sxy = (%5.2f, %5.2f)"):format(sx, sy), 10, 30)
end
