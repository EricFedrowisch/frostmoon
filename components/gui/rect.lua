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
   return (x >= self.x and x <= (self.x + self.width)) and
          (y >= self.y and y <= (self.y + self.height))
end

return Rect
