--
-- Bundle file
-- Code changes will be overwritten
--

-- title:   Dinolode
-- author:  mimi, pati, tito, tomi
-- desc:    motherlode but with dinosaurs
-- site:    https://diogotito.com/experiments/dinoscene
-- license: CC0-1.0
-- version: 0.1
-- script:  lua

-- [TQ-Bundler: tic80-lua-utils]

--- A bunch of global constants and helper functions to work with the TIC-80 API

-------------------------------------------------------
-- Constants
-------------------------------------------------------

SCREEN_WIDTH = 240    --- Screen width, in pixels
SCREEN_HEIGHT = 136   --- Screen height, in pixels
ROOM_WIDTH = 30       --- Screen width, in tiles
ROOM_HEIGHT = 17      --- Screen height, in tiles

RAM_PAL = 0x3FC0 --- Palette RAM address

BTN_UP    = 0 --- `btn[p]` argument to test for the UP button
BTN_DOWN  = 1 --- `btn[p]` argument to test for the DOWN button
BTN_LEFT  = 2 --- `btn[p]` argument to test for the LEFT button
BTN_RIGHT = 3 --- `btn[p]` argument to test for the RIGHT button
BTN_A     = 4 --- `btn[p]` argument to test for the A button
BTN_B     = 5 --- `btn[p]` argument to test for the B button
BTN_X     = 6 --- `btn[p]` argument to test for the X button
BTN_Y     = 7 --- `btn[p]` argument to test for the Y button


-------------------------------------------------------
-- TIC-80 utility functions
-------------------------------------------------------

---Decorate a function to run with VRAM temporarily switched to a given bank
---@param bank 0|1
---@param fn function
---@return function
function on_vbank(bank, fn)
	return function(...)
		local prev = vbank(bank)
		local ret = { fn(...) }
		vbank(prev)
		return table.unpack(ret)
	end
end


-------------------------------------------------------
-- Missing Lua standard library functions and shortcuts
-------------------------------------------------------

-- quick maths
sin, cos, atan = math.sin, math.cos, math.atan
random, randomseed = math.random, math.randomseed
PI, TAU = math.pi, 2*math.pi

unpack = table.unpack -- I just like to use `table.unpack` a lot

---Coerce true and false into 1 and 0, respectively
---@param b boolean|any
---@return 0|1 i # 1 if received truthy, 0 otherwise
function btoi(b)
	return b and 1 or 0
end

---Constrain a number inside an upper and a lower bound
---@param v number # The value to constrain
---@param min number # The lower bound
---@param max number # The upper bound
---@return number clamped # `min` if `v` < `min`, `max` if `v` > `max`, `v` otherwise
function clamp(v,min,max)
	return math.max(math.min(v,max),min)
end

---Linearly interpolates between `from` and `to` by `factor`
---@param from number
---@param to number
---@param factor number # typically in the range 0..1
---@return number
function lerp(from, to, factor)
	return from + factor * (to - from)
end


---Naive recursive table copy.
---**/!\ Prone to infinite recursion!** 
---@param t table # What to copy from
---@return table copy # A deep copy of `t`
function deepcopy(t)
	local new={}
	for k,v in pairs(t) do
		if type(v)=="table" then
			new[k]=deepcopy(v)
		else
			new[k]=v
		end
	end
	return new
end

---Concatenate all given tables from left to right
---@param ... table # The tables to concatenate
---@return table concatenation # A new table with all the numerical keys from all arguments joined together
function cat_tbls(...)
	local tbls, cat = {...}, {}
	for _, t in ipairs(tbls) do
		table.move(t,1,#t, #cat+1,cat)
	end
	return cat
end

---Print out the full structure of a table in the TIC-80 console screen,
---with [trace](lua://trace), to aid debugging.
---@param t table # The table to debug
function dump_tbl(t)
	trace(fmt_tbl(t))
end

---Builds a "pretty-printed" representation of a table, to aid debugging.
---@param t table # The table to pretty-print
---@return string # A nice representation that can be dumped to the console with [trace](lua://trace)
function fmt_tbl(t, i)
	i = i or 0
	local out = {tostring(t)}
	for k,v in pairs(t) do
		out[#out+1] = ("[%s]=%s"):format(
				k,
				(type(v)=="table")
					and fmt_tbl(v, i+1)
					or v)
	end
	local indent = string.rep(" ", i)
	return indent ..
			table.concat(out, "\n "..indent)
end

-- [/TQ-Bundler: tic80-lua-utils]

-- [TQ-Bundler: Vector2]

---@class V2 A 2D vector
---@field x number
---@field y number
V2 = {}
V2.__index = V2 -- setup inherintance

---Shorthand for building {x=x, y=y} with V2 as the metatable,
---i.e., a proper "v2" from here on. x and y can be omitted a la GLSL:
---   v2(1)        -> v2(1, 1)
---   v2()         -> v2(0, 0)
---
--- you can pass another table or V2:
---   v2{x=1, y=2} -> v2(1, 2)
---@return V2
---@overload fun(x: number, y: number): V2
---@overload fun(x: number): V2
---@overload fun(): V2
---@overload fun(v: V2): V2
---@overload fun(t: { x?: number, y?: number }): V2
function v2(x, y)
	if type(x) == "table" then
		---@type { x?: number, y?: number }
		local vectorlike = x
		x = vectorlike.x or 0
		y = vectorlike.y or 0
	elseif not x then            -- e.g. v2()
		x = 0
		y = 0
	elseif not y then            -- e.g. v2(1)
		y = x
	end
	return setmetatable({x=x, y=y}, V2)
end

---Component-wise addition
---@operator add(V2): V2
function V2:__add(v)
	return v2(self.x + v.x, self.y + v.y)
end

---Scale x and y proportionaly to a number
---or perform component-wise multiplication
---@operator mul(number|V2): V2
function V2.__mul(u, v)
	if type(u) == "number" then u = v2(u) end
	if type(v) == "number" then v = v2(v) end
	return v2(u.x*v.x, u.y*v.y)
end

---Get x,y as a list of expressions
---@return number x, number y
function V2:unpack()
	return self.x, self.y
end
---@operator call: number x, number y
V2.__call = V2.unpack -- overload v()


---Overload the tostring() operation
---@return string
function V2:__tostring()
	return ("(%d,%d)"):format(self())
end

--trace(2 * v2(11, 23)) --> (22,46)


-- [/TQ-Bundler: Vector2]

-- [TQ-Bundler: game_constants]

-- Terrain generation
GROUND_Y = 13 --- y coordinate where dirt starts
TERRAIN_WIDTH = ROOM_WIDTH*2
TERRAIN_HEIGHT = ROOM_HEIGHT*2


-- Tiles

TILE_DIRT_1 = 32
TILE_DIRT_2 = 34
TILE_DINO_SMOL_1 = 38
TILE_PTEROSAUR = 204
TILE_STEGOSAURUS = 200

-- Flags

F_COL = 0 --- Solid tiles

-- [/TQ-Bundler: game_constants]

-- [TQ-Bundler: terrain_grid]

grid = {}


function create_empty_grid(width, height)
    local grid = {}
    for y = 1, height do
        local row = {}
        for x = 1, width do
            row[x] = 0
        end
        grid[y] = row
    end
    return grid
end

function tset(x, y, id)
    trace(("tset(%02d, %02d, %3d)"):format(x, y, id))
    grid[y + 1][x + 1] = id
    local mx, my = 2*x, GROUND_Y + 2*y
    mset(mx    , my    , id       )
    mset(mx + 1, my    , id + 0x01)
    mset(mx    , my + 1, id + 0x10)
    mset(mx + 1, my + 1, id + 0x11)
end

function place_dino(x,y,init_id,w,h)
    w = w or 1
    h = h or 1
    id = init_id
    for i = 0, w-1, 1 do
        for j = 0, h-1, 1 do
            id = init_id+i*2+j*32
            tset(x+i,y+j,id)
        end
    end
end


function terrain_generate()
    grid = create_empty_grid(TERRAIN_WIDTH, TERRAIN_HEIGHT)
    for y = 0, TERRAIN_HEIGHT - 1 do
        for x = 0, TERRAIN_WIDTH - 1 do
            tset(x, y, TILE_DIRT_1)
        end
    end

    for i = 1, 3 do
        local x, y = math.random(1, 9), math.random(1, 5)
        tset(x, y, TILE_DINO_SMOL_1)
    end
    -- pterosaur
    place_dino(20,8,TILE_PTEROSAUR,2,2)
    place_dino(10,6,TILE_STEGOSAURUS,2,2)
end

-- [/TQ-Bundler: terrain_grid]

-- [TQ-Bundler: player]

GRAVITY = 1
JUMP_SPEED = 2
MOVE_SPEED = 1
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


function player.update(player)
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

    local speed = MOVE_SPEED
	  * (btn(BTN_A) and 2.0 or 1) -- faster
	  * (btn(BTN_B) and 0.5 or 1) -- slower

	if btn(BTN_UP) then
        player.jumped = true
	end
	-- if btn(BTN_DOWN) and not is_colliding_ground(player.pos) then
	-- 	player.pos.y = player.pos.y+1
	-- end
	if btn(BTN_LEFT) then
		player.pos.x = player.pos.x - speed
        player.flip = 1
	end
	if btn(BTN_RIGHT) then
		player.pos.x = player.pos.x + speed
        player.flip = 0
	end
    if is_colliding_ground(player.pos) then
        player.airtime = 0
    else
        player.airtime = player.airtime+delta
        player.pos.y = player.pos.y + GRAVITY * (player.airtime * 0.005)
    end
    -- "mget=",down_tile," flag=0", fget(down_tile, 0)
end

function player.draw(player)
    -- print(player.flip, 3)

    -- print(("footpos: %02d,%02d"):format(player.pos.x+8,player.pos.y+16))
    -- print(("pos: %02d,%02d, down_tile:%02d, flag=0=%s"):format((player.pos.x+8)//8,(player.pos.y+16)//8,down_tile,fget(down_tile, 0)),4)
    local sx, sy = Cam:world_to_screen(player.pos.x, player.pos.y)
    spr(262, sx, sy, 0, 1, player.flip, 0, 2, 2)
	-- hxw 30 x 17, +1 each side 
	-- map(x//8,y//8,31,18,-(x%8),-(y%8),0,1)

end

function is_colliding_ground(pos)
    -- check for ground
    down_tile = mget((pos.x+8)//8,(pos.y+16)//8)
    return fget(down_tile, F_COL)

end

-- function handle_sprite()

-- end
-- function is_colliding_sides()
--     -- check for directional
-- end




-- [/TQ-Bundler: player]

-- [TQ-Bundler: Cam]

---A minimal camera system
Cam = { x=0, y=0 }


---Positions this camera in a way that puts the point at coordinates *(x, y)*
---at the center of the screen.
---@param world_x number # x coordinate in world pixels space
---@param world_y number # y coordinate in world pixels space
function Cam:look_at(world_x, world_y)
    self.x, self.y =
        world_x - SCREEN_WIDTH/2,
        world_y - SCREEN_HEIGHT/2
    return self
end


---Converts *(x,y)* coordinates from world pixels space to screen space
---based on this camera position.
---Useful for rendering sprites positioned relative to the world
---with the right `x` and `y` parameters passed to [`spr(_, x, y, ...)`](lua://spr).
---@nodiscard
---@param cam { x: number, y: number } # A table with camera positions (or `Cam` if invoked like `Cam:world_to_screen(...)`)
---@param world_x number # x coordinate in world space
---@param world_y number # y coordinate in world space
---@return number screen_x # x coordinate in screen space, given `cam.x`
---@return number screen_y # y coordinate in screen space, given `cam.y`
function Cam.world_to_screen(cam, world_x, world_y)
    return world_x - cam.x,
           world_y - cam.y
end


---Uses the camera coordinates to calculate their parameters `x`, `y`, `sx`, `sy`
---for [`map(x, y, TW+1, TH+1, sx, sy, ...)`](lua://map) calls
---that show the world map from the perspective of a 2D camera at the given coordinates.
---
---Example usage:
---
---    include "tic80-lua-utils"
---    include "Cam"
---    
---    function TIC()
---        Cam:move_with_input()
---        local x, y, sx, sy = Cam:map_params()
---    
---        cls()
---        map(x, y, TW + 1, TH + 1, sx, sy)
---    end
---
---@nodiscard
---@param cam { x: number, y: number } # A table with camera positions (or `Cam` if invoked like `Cam:map_params(...)`)
---@param x_scale? number # Ammount to scale the `x` coordinates, for a horizontal parallax effect. Defaults to 1.0 (no parallax).
---@param y_scale? number # Ammount to scale the `y` coordinates, for a vertical  parallax effect. Defaults to 1.0 (no parallax).
---@return integer x # 1st argument for [map](lua://map) - the x coordinate of the top left map cell to be drawn.
---@return integer y # 2nd argument for [map](lua://map) - the y coordinate of the top left map cell to be drawn.
---@return integer sx # 5th argument for [map](lua://map) - the x screen coordinate where drawing of the map section will start
---@return integer sy # 6th argument for [map](lua://map) - the y screen coordinate where drawing of the map section will start
function Cam.map_params(cam, x_scale, y_scale)
    x_scale = x_scale or 1.0
	y_scale = y_scale or x_scale
	local x, y = x_scale * cam.x, y_scale * cam.y
	return x // 8,   y // 8,  -- x, y
           -(x % 8), -(y % 8) -- sx, sy
end


-- "legacy" cam:move adapted from parallax.lua

Cam.move_speed = 1.0

Cam.move_bounds = {
    left   = 0,
    top    = 0,
    right  = 16*TERRAIN_WIDTH - SCREEN_HEIGHT,
    bottom = 16*TERRAIN_HEIGHT - SCREEN_HEIGHT,
}

---Update `x` and `y` coordinates with directional input,
---using `A` to move faster and `B` to move slower.
function Cam:move_with_input()
	local speed = self.move_speed
	  * (btn(BTN_A) and 2.0 or 1) -- faster
	  * (btn(BTN_B) and 0.5 or 1) -- slower

	local dx, dy =
		btoi(btn(BTN_RIGHT)) - btoi(btn(BTN_LEFT)),
		btoi(btn(BTN_DOWN))  - btoi(btn(BTN_UP))

    self.x, self.y = self.x + speed*dx, self.y + speed*dy
	self:enforce_bounds()
end

function Cam:enforce_bounds(bounds)
    bounds = bounds or self.move_bounds
    self.x, self.y =
		clamp(self.x, bounds.left, bounds.right),
		clamp(self.y, bounds.top, bounds.bottom)
    return self
end


-- [/TQ-Bundler: Cam]

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

-- <TILES>
-- 001:9999999999999999999999999999999999999999999999999999999999999999
-- 009:4444444444444444444444444444444444444444444eee4444eeeee444eeeeee
-- 010:00000000000000000000000000000000000000000000000000ee00000eeee000
-- 011:0000000000000000000000000000007000007070000075700007757700576577
-- 012:0007000000070000707700007077700777777077757777777577675755756557
-- 013:0007000770070007700770077007707770777777777775775777657757576576
-- 014:0000000000000000000000000000000000000000050000000500000055050500
-- 015:000000000000000000000000000000000000000000000000000000000000dd00
-- 025:eeefeeeeffffeeffeeeefffdeeddddddddddddffdfddffffdddffdffffdfffee
-- 026:feeeffeeeffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 027:d655655575555555d6556676de6656e7dd756efefff6deeeffffffdeeeeffffd
-- 028:556565555555555556556676676656e7dd756efefff6deeeffffffdeeeeffffd
-- 029:56556556555555555555566576567e76e767efe7ee6eedddeeddffffddffffee
-- 030:5655655e555555565555566776567e7de767deddee6eedffeeddffffddffffee
-- 031:eeeddddeefffdefffddfffeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 032:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 033:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 034:ddddedddeeeeeefedddfeeeedddddddedfddddddfefffdfdfffffffdeeefffff
-- 035:dddddeddffeeeeeeeeeeedfddedddddddddddddddfdddfffdddffeffffdfffee
-- 036:eeeeeeffedddeeefddccdeeedcccdddedccccdddfddcdddcffdddedceeedeedc
-- 037:ffffeeeeffeecdddeddcccedddccccddccdccccecccdcccfcdcdcccdccdccccd
-- 038:eeeeefffddeddeefdddfdddeddddccccffedccdcfefeecccffffedcceeccdedc
-- 039:ffffeeeeeffeeeddeeeeddfddeddddddcddddddfccccdeffccccccefccdcccee
-- 048:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 049:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 050:efeeffefeeeeeeffddeeefeeffddeeeefffffdedffffffffedfeffffdedddddd
-- 051:ffffeeeeffeefeeeeeeeeeddeeeeedffedddffffffffffffffffdefeddedddde
-- 052:efeefdedeedcccddeeccdccdddcccdcdfeccccccfddcccccfffddccceefffddd
-- 053:ccccccdedcccddeefdeddeeddffeeeffdfeeffffdeffffffdfffdfffffffffee
-- 054:efcccddceedccccdddedccccffdddcccffffddccffdffddefffffffdeeffefff
-- 055:cdddccceccdccccedccccccdccccccdfcccccdffcccedfffdddfffffffffffee
-- 064:bbbbbbbbaaabbbbbaaaaaabbaaaaaaabaaaaabaaabaaaaaabbbbbaaabbbbbbbb
-- 065:bbbbbbbbbbbbbaaabbaabaaaaaaaaaaaaaaaaaaaaaaaaabbaaabbbbbbabbabbb
-- 066:0ee0ff0fedeeeeefdddfdeee0ddddddefefdddddfffffdfdeffffffdeeefffff
-- 067:ff0fe0eefffeeed0eeeeddddeeddddf0ddddddd0dfddfff0dddffdffffdfffee
-- 068:0eeeffff0deeeeef00dfdeee0ddddddefefdddddfffffdfdeffffffdeeefffff
-- 069:ffffeeeefffeeed0eeeeddd0eedddd00ddddddd0dfddfff0dddffdffffdfffee
-- 070:0ee0ff0fedeeeeefdddfdeeedddddddefefdddddfffffdfdeffffffdeeefffff
-- 071:ff0fe0eefffeeeddeeeeddddeeddddfddddddddfdfddffffdddffdffffdfffee
-- 077:0000000000000000000000220000233300023333002333330233333302333332
-- 078:0000000022222220222222222222222232222222322222222222222222222222
-- 079:0000000000000000200000002220000022120000222120002222120022212100
-- 080:bbbbbbbbaaaabbbbabaababbaaaaaaaaaaaaaaaabbbaaaaababbbbaabbbbbbbb
-- 081:bbbbbbabbbbbaaaabbaaaaaaaaaaaaaaabaaaaaaaaaaabbbaaabbbbbbbbbbbbb
-- 082:efeeffef0eeeeeff0deeefee0fddeeeeffffddeeffdffffdffffffff0effe0ff
-- 083:ffffeeeeffeefeeeeeeeeed0eeeeedf0eeeddfffdddfffffffffdff000fff0e0
-- 084:efeeffef0eeeeeff0deeefee0fddeeeeffffddeeffdffffd0fffffff0effefff
-- 085:ffffeeeeffeefeeeeeeeeed0eeeeed00eeeddff0dddfffffffffdfffffffffee
-- 086:efeeffefdeeeeefffdeeefeedfddeeeeffffddeeffdffffdffffffff0effe0ff
-- 087:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdff000fff0e0
-- 090:0000000000000000000000000000000000000000000000000000000001100000
-- 092:0000000000000000000000020000009200099899009998990999888909980082
-- 093:2223332222222222222222222222122233333333211111113222222231211111
-- 094:2222222222222222222222222221222232332322111111112222222211111111
-- 095:2222121022212120222212112212211122221221111111212222222111112121
-- 103:0000000000000000000000000000000900000999000099930009999300993393
-- 104:0000009900099999099933999993993993939939939399393399339993999990
-- 105:9990000033990000393900003339000039990000399900009990000008000000
-- 106:0001110011010000001110000010000001000000010000001000000010000000
-- 107:0000000000000000000000000099899909998999999888889980000088800000
-- 108:0888000209980000999800009988000099880000898800008898000009980000
-- 109:3121122231212222312122223121222231212222312121213121111231201111
-- 110:2221222222222222222222222222222122121212212121211212121111111111
-- 111:2212212122212120121221202121212012112120211121201111212011102120
-- 112:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 113:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 114:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 115:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 116:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 117:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 119:0993999309933399099993990993399000999980000990820000002300000233
-- 120:9999000099800002008022230022333322333333333333333333333233333322
-- 121:0802222222222222333222223333222233222222222222222222222222222222
-- 122:2222200022222222222222222222222222222222222222222222222222222222
-- 123:9980000029800000222200002222220022222222222222222222222222222222
-- 124:0888000009980000099800000998000009980000199800002198000022180000
-- 125:3120001131200000312100003121100031211100312111102120111131200111
-- 126:1111111111888110088888000088800000988000009880000098800310998031
-- 127:1000212000002120000321200031212003112120311221201120212012002120
-- 128:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 129:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 130:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 131:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 132:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 133:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 134:0000000000000000000022220022281802288919028999192289992928999929
-- 135:0000233300002333233333332222222299212121999212129992212199992212
-- 136:3333322233333222333322222222222221212222121212222121212212121222
-- 137:2222222222222222222222222222222222222222222222222222222222222222
-- 138:2222222222222222222222222222222922222229222222292222222922222222
-- 139:2222222222222222999922223338922233389222333892223338922299992222
-- 140:2121000022120000212120002212100021211100121211002121110012111110
-- 141:3120001121200001212000003120000021200000212000002120000221200031
-- 142:1188831111993112119211200121120002112100311281101129811112998111
-- 143:2000212000002120000021200000212000002120000021200000212010002120
-- 144:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 145:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 146:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 147:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 148:ddddedddeeeeeefedddfeeeedddddddedfddddddfefffdfdfffffffdeeefffff
-- 149:dddddeddffeeeeeeeeeeedfddedddddddddddddddfdddfffdddffeffffdfffee
-- 150:2899993928999929289999392888883828999939289999292895992925956925
-- 151:9999212199992111999921118888211199992111999921119999251199596511
-- 152:2121212211111122111111221111111211111112151111111561115155651556
-- 153:2222222222222222222222222222222222222222252222221522622255156511
-- 154:222222222222222222222222222222222222222222222212222221211111dd11
-- 155:22222121222222122221212122221212212121211212ee12212eeee1111eeeee
-- 156:2121111012111110211111101211111111111111111111111111111111111111
-- 157:2120021121202112212311202121120021212000212200002920000099880000
-- 158:3088801100998001009980000099800000998000008880000999880099998880
-- 159:1100212011102120111121200111212000112120000121200000292000099988
-- 160:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 161:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 162:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 163:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 164:efeeffefeeeeeeffddeeefeeffddeeeefffffdedffffffffedfeffffdedddddd
-- 165:ffffeeeeffeefeeeeeeeeeddeeeeedffedddffffffffffffffffdefeddedddde
-- 166:556565555555555556556676676656e7dd756efefff6deeeffffffdeeeeffffd
-- 167:56556556555555555555566576567e76e767efe7ee6eedddeeddffffddffffee
-- 168:556555565555555556556676676656e7dd756efefff6deeeffffffdeeeeffffd
-- 169:5565655e555555565555566776567e7de767deddee6eedffeeddffffddffffee
-- 170:eeeddddeefffdefffddfffeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 171:eeefeeeeffffeeffeeeefffdeeddddddddddddffdfddffffdddffdffffdfffee
-- 172:eeeddddeefffdefffddfffeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 173:eeefeeeeffffeeffeeeefffdeeddddddddddddffdfddffffdddffdffffdfffee
-- 174:eeeddddeefffdefffddfffeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 175:eeefeeeeffffeeffeeeefffdeeddddddddddddffdfddffffdddffdffffdfffee
-- 192:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaabbaabaaaaaaaaaaaaaaaaabbaaabbbbb
-- 193:bbbbbbbbbbbbaaaaaaaaaaaaaabaaabaaaaabbbbabbbbbbbbbbbbbbbbbbbbbbb
-- 194:bbbbbbbbaaabbabbbaaaaaabaaaaabaabbbbaaaabbbbbbbabbbbbbbbbbbbbbbb
-- 195:bbbbbbbbbabbbbbbbbbbbbbbaabbbbbbaaabaabaaaaaaaaabbaaaaaabbbbbaaa
-- 196:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 197:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 198:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 199:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 200:eedeffffeceddeeffeeedddefecdddddffcffdddddffffddeeecefffeeefceff
-- 201:feedddedffcfefdeecfcffffdeccffdddeeecccdddddccccdddeecceffddeefc
-- 202:eefffffdfffdcfddffffcdcdddfddccedddcdceeddddcdeeeddeccffccfeccff
-- 203:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffccdddffccfffcccfce
-- 204:eeeeffffddeeeeefdcccccccdddddcccfffdddddfefffdfdfffffffceeefffcf
-- 205:ffffeeeefffeeeddcccccccdcccddccddcccccffceefcfffdfffcdfffffcffee
-- 206:eeeeffffddeeeeefddccdeeedcccdddefcfdcdddccffcdfdffcffcfdeeecffff
-- 207:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 208:bbbbabbbbbbbbbbbbbbbbbbabbbbaabaaaaaaaaaaabaaaabaaabbbbbbbbbbbbb
-- 209:bbbbbaaabaabaabaaaaaaaaaaaaaaabbaaabbbbbabbbbbabbbbbbbbbbbbbbbbb
-- 210:aaabbbbbabaabbabaaaaaaaaabaaaaaabbbbbaaababbbbbabbbbbbbbbbbbbbbb
-- 211:bbbbbbbbbbbbabbbbabbbbbbabaaabbbaaaaaababaaaaaaabbbbaaaabbbbbbbb
-- 212:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 213:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 214:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 215:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 216:efeeffefeeeeefcfddeeeffcffddeeecffffddefffdfffffffffffffeeffefff
-- 217:ffffceccffcccfcfddcccccdedccdcddccdddcdcfccdddcceccccdcddeeccccd
-- 218:cffeecfffddddcddfdcddeddcdccdccccddcdccccfccdcccfdcddcdcccdfcddc
-- 219:cfccfeecccfffeeeccfeeeddcceeedffcceddfffccccfffffcccdfffffffffee
-- 220:efeefcefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 221:ffcfeeeeffcefeeeeecceeddeeeccccceeecccceddccffccffcfdcccffcfcfee
-- 222:efeecfcfeeeeecffffeeefceeeedeecccceecceecfdffffdccccffffcccfffff
-- 223:ffffeeeeffeefeeeeecceeddceccedffeeccdfffcdcfcfffffcfcfffffcfcfcc
-- 224:9999999999999999999999999999999999999999999979999979797999797979
-- 225:9999999999999999999999999999999999999999979999999797999797979797
-- 226:bbbbbbbbaaabbbbbaaaaaabbaaaaaaabaaaaabaaabaaaaaabbbbbaaabbbbbbbb
-- 227:bbbbbbbbbbbbbaaabbaabaaaaaaaaaaaaaaaaaaaaaaaaabbaaabbbbbbabbabbb
-- 228:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 229:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 230:eeeeffffddeeeeefdddfdeeedddddddefffdddddfefffdfdfffffffdeeefffff
-- 231:ffffeeeefffeeeddeeeeddfdeeddddddddddddffdfddffffdddffdffffdfffee
-- 232:eeeeffffddeeeeefdddfdddfddddddddfffdddddfefffdfdfffffffddddfffff
-- 233:cccfeeecccccfceecccefcccffffeccceeeeccffdfdefffeddddeeddfeddfddd
-- 234:cccccceeeeeedecccffccfedffccccfeffcccffeeeffffddddeddddcdddddfcc
-- 235:ffffeeeefccceeddeeeeceddeeddcedddddcceffdfdcdfffccdffffffccfffee
-- 236:eeeeffffdcccceefdcdfcceedccdddeeffcddddefeccfdfdfffcfffdeeecffff
-- 237:ffcfceccfffccecdeeecdcfecedddcddecdddcffdfcdfcffdddccdffffdfccee
-- 238:eeeccfffecceecefceeeeeceeeecdddcffcccccdfecffdccffccfffceeecffff
-- 239:ffcfceceffceccddeeceddfdeecdddddcdcdddffdcddffffdcdffdffffdfffee
-- 240:777777775555555556556676676656e7dd756efefff6deeeffffffdeeeeffffd
-- 241:77777777555555555555566576567e76e767efe7ee6eedddeeddffffddffffee
-- 242:bbbbbbbbaaaabbbbabaababbaaaaaaaaaaaaaaaabbbaaaaababbbbaabbbbbbbb
-- 243:bbbbbbabbbbbaaaabbaaaaaaaaaaaaaaabaaaaaaaaaaabbbaaabbbbbbbbbbbbb
-- 244:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 245:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 246:efeeffefeeeeeeffddeeefeeffddeeeeffffddeeffdffffdffffffffeeffefff
-- 247:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- 248:dfddffefddddddffdddddfddffddddddffffddddffdffffdffffffffeeffefff
-- 249:ffffdddddfffffffdfdfffefddddddfdddddddddddddfdddffddddddffffffff
-- 250:ddffffcfffdffcccffffdcccffddcccfddddccffdfddccfedddddfffffffffff
-- 251:fcccfeeeccccfeeefecffeddfccfedffecffdfffdcffffffffffdfffffffffee
-- 252:efeecfefeeeeeeffddeeeceeffddeceeffffddeeffdffcfdffffffffeefffcff
-- 253:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffec
-- 254:efecffefeeeeceffddeecceeffddeceefffccceefcfffffdffffffffceffefff
-- 255:ffffeeeeffeefeeeeeeeeeddeeeeedffeeeddfffdddfffffffffdfffffffffee
-- </TILES>

-- <SPRITES>
-- 001:0000005500005555000055550005555000055550000555000005550000055555
-- 002:55555000ca55550055555550000c0c0000000000000000000000000055555500
-- 003:0000005500005555000055550005555300055553000555330005553300055555
-- 004:55555000ca5555005555555033333000cb3cb000333333003333300055555500
-- 006:0000bbbb00bbbbbb0bb00b0b0b000b0bbb999990b09000900099999000000000
-- 007:bb000b00bbbbbbbbb00b000bb99990000900900009999000000c000000c00000
-- 017:5000575550005577550555557555555507555555007755550000755000007755
-- 018:5555500077770000555500005555000055550000555550000075500000775500
-- 019:5000575550005577550555557555555507555555007755550000755000007755
-- 020:5555500077770000555500005555000055550000555550000075500000775500
-- 022:0000cc0000000ccc000000cc000ccccc00000c0c0000cc000000c00000000000
-- 023:ccc00000c000000000000000cccc000000000000c0000000cc00000000000000
-- </SPRITES>

-- <MAP>
-- 007:00000000000000000000000000000000a4b4c4d4e4f40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:00000000000000000000000000000000a5b5c5d5e5f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:00000000000000000000000066768696a6b6c6d6e6f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:00000000000000000000000067778797a7b7c7d7e7f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:00000000000000000000000068788898a8b8c8d8e8f80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:0000000000000000a0b0c0d069798999a9b9c9d9e9f9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:0212021202120212a1b1c1d16a7a8a9aaabacadaeafaf112021202120212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:031303130313031303130313031303130313031303130313031303130313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:021202120212ccdcecfc0212021202120212021202120212021202120212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:031303130313cdddedfd0313031303130313031303130313031303130313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:223222322232cedeeefe2232223222322232223222322232223222322232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:233323332333cfdfefff2333233323332333233323332333233323332333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:223222322232223222322232223222322232223222322232223222322232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:031303130313031303130313031303130313031303130313031303130313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:fffedca8654322110000000000000000
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:9bcdeeffffeedcb96432110000112346
-- 004:579bdeffedb987789bcddcb975310013
-- 005:56789abcdffecbbbba87544443100234
-- 006:79bdefedb8ba97656787656532345656
-- 007:43210123579bcdefedca865432112234
-- 008:9acdeffedccddca96532112210012356
-- 009:4201369cfc9631234201369cfc963123
-- 010:8acefeca86468ac963579b9753101357
-- 011:79bccb97410358bdffdb853357899856
-- 012:655679bcdeeeedca87655679abba9877
-- 013:0000ffff0000ffff0000ffff0000ffff
-- 014:0369cffdb98653210000000000000000
-- </WAVES>

-- <SFX>
-- 000:0e001e003e006e0f9e0ece0cee0afe08fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00270000000000
-- 001:00d010d030d060e090f0c0f0e0f0f0f0f0f0f0f0f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f0003f0000000000
-- 002:03f723c34380635e730c930ab309c308d308d308e308e308e308e308f308f308f308f308f308f308f308f308f308f308f308f308f308f308f308f308b80000000000
-- 012:030013012300330f430043014300430f430043014300430f430043014300430f330023011300030f030003011300230f330043016300930fc300f301600000000000
-- 051:0ec01ec03ec06ecf9ececedceedafe08fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe003f0000000000
-- 061:330033013300330f430043014300430f430043014300430f430043013300330f230013010300030f030013011300230f230043016300930fc300e301604000000000
-- 062:04001400240034003400440044004400540064006400740084009400a400b400b400c400d400d400d400e400f400f400f400f400f400f400f400f400305000000000
-- 063:0f001f003f006f009f00cf00ef00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00300000000000
-- </SFX>

-- <PATTERNS>
-- 000:400004000010000020000000400004000000000020000010400004000000000020000010400004000000000020000000400004000010000020000000400004000020000020000020400004000000000020000000400004000000000020000000400004000010000020000000400004000000000020000000400004000000000020000000400004000000000020000000400004000010000010000000400004000000000020000000400004000000000020000000400004000000000020000000
-- 001:000000000020000000000020000000000020000000000020000000000020000000000020000000000020000000000000000000600016400026000000000000000020400026000000000000000020400026000000000000000020400026000000000000600018400026000000000000000020400026000000000000000020400026000000000000000020400026000000000000600016800016000000000000000020400026000000000000000020400026000000000000000020400026000000
-- 015:000000000020000000000020000000000020000000000020000000000020000000000020000000000020000000000000000000600016400026000000000000000020400026000000000000000020400026000000000000000020400026000000000000600018400026000000000000000020400026000000000000000020400026000000000000000020400026000000000000600016800016000000000000000020400026000000000000000020400026000000000000000020400026000000
-- 016:000000600018400026000010000000000000400026000000000000000000400026000000000000000000400026000000000000600016800016000000000000000000400026000000000000000000400026000000000000000000400026000000000000600018400026000000000000000000400026000000000000000000400026000000000000000000400026000000000000600016800016000000000000000000400026000000000000000000400026000000000000000000400026000000
-- 031:0000000000c00000000000000000000000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000000000005000ca7000ca8000ca7000ca0000008000ca7000ca6000ca1000c06000ca6000ca6000ca7000ca8000ca0000000000005000ca7000ca8000ca7000ca0000008000ca7000ca6000ca1000c06000ca6000ca6000ca8000ca7000ca000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:0000000000c00000000000000000000000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000c00000000000005000ca7000ca8000ca7000ca0000008000ca7000ca6000ca1000c06000ca6000ca6000ca7000ca8000ca0000000000005000ca7000ca8000ca7000ca0000008000ca7000ca6000ca1000c06000ca6000ca6000ca8000ca7000ca000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:104000144020144120000000000000000000000000000000000000000000000000000000000000000000000000000000ec0000
-- </TRACKS>

-- <FLAGS>
-- 000:00000000000000000000000000000000000000000000000000101010101010101010101010101010000000000000000010101010101010100000000000000000101010101010101000000000000000001010101010101010000000000000000000000000000000000000000000000000101010100000000000000000000000001010101000000000000000000000000010101010000000000000000000000000101010100000101010101010101010100000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c818195a5a5b6c6c6d200badea7f07038b764257179852848b23c55694848593838ffe2ceaa754d9d6148855040
-- 001:00000075b2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PALETTE>

