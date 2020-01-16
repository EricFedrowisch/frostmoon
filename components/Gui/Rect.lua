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
   local container = self:get_container()
   if container ~= nil then
      local msg = {
         type = "update_position",
         args = {self.x, self.y, self.z}
      }
      self:direct_msg(container, msg)
   end
end

function Rect:check_bounds(n)
   return n >= 0 and n <= 1
end

--Change Proportionate X position of Rect.
function Rect:update_px(px)
   if not self:check_bounds(px) then error("PX value out of bounds.") end
   self.px = px
   self:update_position(_G.vc.s_width * px, self.y, self.z)
end

--Change Proportionate Y position of Rect.
function Rect:update_py(py)
   if not self:check_bounds(py) then error("PY value out of bounds.") end
   self.py = py
   self:update_position(self.x, _G.vc.s_height * py, self.z)
end

function Rect:center_on(px,py)
   self:update_px(px)
   self:update_py(py)
   self:move_position(-self.width/2, -self.height/2)
end

--Make a change to absolute postion based on a distance.
function Rect:move_position(dx, dy)
   self:update_position(self.x + dx, self.y + dy)
end

Rect.event_types = {
   --resize
}

return Rect
