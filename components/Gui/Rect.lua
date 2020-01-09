--[[
Rect object for storing/testing collisions.
]]
local Rect = {}
Rect.defaults = {
   x = 0,
   y = 0,
   z = 1,
   width = 100,
   height = 100
}

function Rect:inside(x, y)
   return (x >= self.x and x <= (self.x + self.width)) and
          (y >= self.y and y <= (self.y + self.height))
end

function Rect:update_size()
   local container = self:get_container()
   self.width, self.height = container.width, container.height
end

--Make a change to postion. Changes are either relative or absolute.
--Absolute by default.
function Rect:update_position(dx, dy, relative)
   local x, y = dx, dy
   if relative ~= nil then x, y = self.x + dx, self.y + dy end
   self.x, self.y = x or self.x, y or self.y
end

Rect.event_types = {
   --resize
}

return Rect
