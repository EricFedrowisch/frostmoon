--[[
Rect object for storing/testing collisions.
]]
local Rect = {}
Rect.defaults = {
   x = 0, --Absolute x value
   y = 0, --Absolute y value
   z = 1,
   px = 0, --Proportionate x value (proportion from the left side of screen)
   py = 0, --Proportionate y value (proportion from the top of the screen)
   width = 100,
   height = 100
}

function Rect:inside(x, y)
   return (x >= self.x and x <= (self.x + self.width)) and
          (y >= self.y and y <= (self.y + self.height))
end

function Rect:update_size(width, height)
   self.width, self.height = width, height
end

--Change to absolute postion x, y, z(optionally).
function Rect:update_position(x, y, z)
   self.x, self.y = x, y
   self.z= z or self.z
end

--Make a change to absolute postion based on a distance.
function Rect:move_position(dx, dy)
   self.x, self.y = self.x + dx, self.y + dy
end

Rect.event_types = {
   --resize
}

return Rect
