---decorate a function to run with VRAM
---temporarily switched to a given bank
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
