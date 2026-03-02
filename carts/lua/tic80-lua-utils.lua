--- A bunch of global constants and helper functions to work with the TIC-80 API

-------------------------------------------------------
-- Constants
-------------------------------------------------------

SW = 240    --- Screen width, in pixels
SH = 136    --- Screen height, in pixels
TW = 30     --- Screen width, in tiles
TH = 17     --- Screen height, in tiles

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