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
