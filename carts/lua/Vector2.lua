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
