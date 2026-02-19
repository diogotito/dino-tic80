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
