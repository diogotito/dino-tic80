-- title:   Dinolode
-- author:  mimi, pati, tito, tomi
-- desc:    motherlode but with dinosaurs
-- site:    https://diogotito.com/experiments/dinoscene
-- license: CC0-1.0
-- version: 0.1
-- script:  lua

include "tic80-lua-utils"
include "Vector2"
include "tic80-lua-utils"

GRAVITY = 1
JUMP_SPEED = 2
player={
    pos = {x=0,y=0},
    dir = {x=0,y=0},
    hitbox = {x=1,y=3,w=6,h=5},
    jumped = false,
    max_jump_h = 4,
    -- max_jump = 10, --
    jump_v = 0,
    -- jump_spd = 5
    airtime =0,
    flip = 0,
}


local delta, last = 0, time()
jump_duration = 4

include "game_constants"
include "terrain_grid"
include "Cam"


function BOOT()
    terrain_generate()
end


function TIC()
    -- cls(7)
    -- local vec = v2(10) + v2(100)
    -- print("hi", vec.x, vec.y, 5)\

    local now = time()
    delta = now - last
    last = now

    -- trace(delta)
    if player.jumped then
        player.pos.y = player.pos.y - JUMP_SPEED
        if is_colliding_ground(player.pos) then
            player.jumped = false
        end
    end

	if btn(BTN_UP) then
        player.jumped = true
	end
	-- if btn(BTN_DOWN) and not is_colliding_ground(player.pos) then
	-- 	player.pos.y = player.pos.y+1
	-- end
	if btn(BTN_LEFT) then
		player.pos.x = player.pos.x-1
        player.flip = 1
	end
	if btn(BTN_RIGHT) then
		player.pos.x = player.pos.x+1
        player.flip = 0
	end
	

	cls(0)
    map(0,0,30,17,0,0,0,1)

    -- print(player.flip, 3)
    if is_colliding_ground(player.pos) then
        player.airtime = 0
    else
        player.airtime = player.airtime+delta
        player.pos.y = player.pos.y + GRAVITY * (player.airtime * 0.005)
    end
    -- "mget=",down_tile," flag=0", fget(down_tile, 0)

    -- print(("footpos: %02d,%02d"):format(player.pos.x+8,player.pos.y+16))
    -- print(("pos: %02d,%02d, down_tile:%02d, flag=0=%s"):format((player.pos.x+8)//8,(player.pos.y+16)//8,down_tile,fget(down_tile, 0)),4)
    spr(262,player.pos.x,player.pos.y,0,1,player.flip,0,2,2)
	-- hxw 30 x 17, +1 each side 
	-- map(x//8,y//8,31,18,-(x%8),-(y%8),0,1)
    
end

function is_colliding_ground(pos)
    -- check for ground
    down_tile = mget((pos.x+8)//8,(pos.y+16)//8)
    return fget(down_tile, 0)
    
end

-- function handle_sprite()

-- end
-- function is_colliding_sides()
--     -- check for directional
-- end


