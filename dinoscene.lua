-- title:   dinoscene
-- desc:    gwaaaaaaarrgh
-- site:    diogotito.neocities.org
-- license: your mom
-- version: -3.1415926535...
-- script:  lua



-------------------------------------
-- GAME CONSTANTS                  --
-------------------------------------

local GROUND_Y = 6



-------------------------------------
-- UTILITIES AND TIC-80 CONSTANTS  --
-------------------------------------

local RAM = {
	PALETTE        = 0x3FC0,
	SCREEN_OFFSET  = 0x3FF9,
}

-------------------------------------
--- a "class" for "Vector2"s
local V2 = {}
V2.__index = V2 -- setup inherintance

--- Shorthand for building {x=x, y=y}
--- with V2 as the metatable,
--- i.e., a proper "v2" from here on.
--- x and y can be omitted a la GLSL:
---   v2(1)        -> v2(1, 1)
---   v2()         -> v2(0, 0)
--- you can pass another table or V2:
---   v2{x=1, y=2} -> v2(1, 2)
local function v2(x, y)
 if type(x)=="table" then -- v2{...}
 	x, y = x.x or 0, x.y or 0
 end
	if not x then     -- e.g. v2()
		x = 0
		y = 0
	elseif not y then -- e.g. v2(1)
	 y = x
	end
	return setmetatable({x=x, y=y}, V2)
end

--- Overload the (+) operator for V2s
function V2:__add(v)
	return v2(self.x+v.x, self.y+v.y)
end

--- overload the (*) operator for V2s
function V2.__mul(u, v)
	if type(u)=="number"then u=v2(u) end
	if type(v)=="number"then v=v2(v) end
	return v2(u.x*v.x, u.y*v.y)
end

--- *(SHORTHAND)*
--- Get x,y as a list of expressions
function V2:unpack()
	return self.x, self.y
end
V2.__call = V2.unpack -- overload v()


--- Overload the tostring() operation
function V2:__tostring()
	return ("(%d,%d)"):format(self())
end

-- tests (uncomment and check output)
--trace(2 * v2(11, 23)) --> (22,46)

-- end of "class V2"
-------------------------------------


--
-- TIC-80 utility functions
--

-- Accepts {x=,y=} table or v2
local function offset_screen(ox, oy)
	poke(RAM.SCREEN_OFFSET+0, ox)
	poke(RAM.SCREEN_OFFSET+1, oy)
end



-------------------------------------
-- MAP GEN                         --
-------------------------------------

local DIRT_BASE = 16

for cy = 6,16 do
	for cx = 0,30 do
		poke( 0x8000 + 0xF0 * cy + cx
		    , DIRT_BASE + (cx+cy) % 2)
	end
end

for i = 1,8 do
	local tx = math.random(1, 16)
	local ty = math.random(8, 16)
		poke(0x8000 + 0xF0 * ty + tx, 32)
end

-- Justify inclusion of a jet pack
do
	local function pit(x, d)
		for cy = 6, 5+d do
			poke( 0x8000 + cy*0xF0 + x
			    , DIRT_BASE + 2)
		end
		poke(0x8000+(6+d)*0xF0+x,DIRT_BASE+3)
	end
	pit(18, 0)
	pit(23, 7) pit(24, 6) pit(25, 7)
end


-------------------------------------
-- GAME STATE                      --
-------------------------------------

offset = v2()

function update()
	offset.x = (t % 256) - 128
end


function draw_overlay()
	vbank(1)
	cls()
	
	print(offset)
	
	vbank(0)
end

-------------------------------------
-- GAME LOOP                       --
-------------------------------------

t=0

function TIC()
	--------- update ----------
	
	update()
	
	---------- draw -----------
	
	vbank(0)
	
	-- dirt
	map()
	-- the sun
	circ(230, 0, 20, 4)
	-- dino
	spr(48, 20, 24, 0, 1, 0, 0, 3, 3)
	line(42, 32, 55, 26, 0)
	print("gwaaaaaaarrgh", 56, 20, 0)
	-- dude
	spr(83, 120, 40, 15)
	
	offset_screen(offset.x, offset.y)
	
	draw_overlay()
	
	--------- advance t ----------
	
	t = t + 1
end
-- <TILES>
-- 000:9999999999999999999999999999999999999999999999999999999999999999
-- 001:9999999999999999999999999999999999999999999999999999999999999999
-- 016:1111111111111111166216612662261221112622111112211611661116111111
-- 017:1111111111266111222221112111221216111222166111211611111111111161
-- 018:0000000000200000000001000000000000000000001000000000001000000000
-- 019:0000000000001000000000000070007000700070076703670367076776633666
-- 032:9818111199111891911919191111111119119119981981911911911991111191
-- 033:1111111111111111111111111111111111111111111111111111111111111111
-- 049:0000000000000000000000000000000000006666000660660006666600066666
-- 050:0000000000000000000000000000000066600000666600006666000066660000
-- 064:0000000060000000600000006600006666600666666666666666666606666666
-- 065:0006666600666666666666606666666666666600666666006666666666666606
-- 066:6666000066660000000000006600000000000000000000000000000000000000
-- 080:0066666600066666000066660000066600000666000006600000060000000660
-- 081:6666660066666600666660006666000006600000006000000060000000660000
-- 083:f35555ff3f3333fff555555fff6060ffff6666fff63222ffff22225ff5ffffff
-- 084:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 099:0055550000444400055555500066660000166100043113407033330700500500
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:2f2a35443d386256539a5d40a981433b42626f7777989da0c2b8a9d9dbba000404ffffff000000000000000000000000
-- </PALETTE>

