--[[
Rect object for storing/testing collisions.
]]
local Rect = {}
Rect.defaults = {
   ["x"] = 100,
   ["y"]= 100,
   ["z"] = 1,
   ["width"] = 100,
   ["height"] = 100,
}

function Rect:inside(x, y)
   local fx, fy = self.x, self.y
   return (x >= fx and x <= (fx + self.width)) and
          (y >= fy and y <= (fy + self.height))
end

return Rect
