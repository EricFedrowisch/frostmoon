--[[
Rect object for storing/testing collisions.
]]
local Rect = {}
Rect.defaults = {
   ["x"] = 0,
   ["y"]= 0,
   ["z"] = 1,
   ["width"] = 100,
   ["height"] = 100,
   ["draggable"] = false,
   ["last_move_pos"] = {0,0},
   ["dt_pressed"] = 0,
}

function Rect:update_size()
   local container = self:get_container()
   self.width, self.height = container.width, container.height
end

function Rect:last_move_position()
   local dx, dy
   if _G.OS ~= "iOS" then --If you are not mobile then...
      dx, dy = love.mouse.getPosition() --Just get mouse position
   else --Else if mobile then...
      dx, dy = self:get_mobile_touch_pos() --Get mobile touch postion
   end
   return dx, dy
end

function Rect:get_mobile_touch_pos()
   local on_touch = {} --Make empty list of touches on self
   local tx, ty
   for i, id in ipairs(love.touch.getTouches()) do --for each touch in touches...
      local x, y = love.touch.getPosition(id) --Get touch position
      if self:inside(x,y) then --If touch is inside self
         on_touch[#on_touch + 1] = {x,y} --Then add it to list of touches on self
      end
   end
   if #on_touch > 0 then --If there are more than one touch that collides..
   --Average the touche positions
      local x, y = 0, 0
      for i, v in pairs(on_touch) do
         x = x + v[1] --Add up x values
         y = y + v[2] --Add up y values
      end
      tx = math.floor(x / #on_touch)
      ty = math.floor(y / #on_touch)
   end
   return tx, ty
end

function Rect:drag(msg)
   if self.pressed then
      self.dt_pressed = msg.dt + self.dt_pressed
      if self.dt_pressed >= 0.1 then
         self.dragging = true
      end
      local mx, my = self:last_move_position()
      if mx ~= nil and my ~= nil then
         --Calculate the change between the last point and the mouse cursor
         local dx = self.x - (self.last_move_pos.mx - mx)
         local dy = self.y - (self.last_move_pos.my - my)
         self:update_position(dx, dy)
         self.last_move_pos.mx, self.last_move_pos.my = mx, my
      end
   end
end

--Make a change to postion. Changes are either relative or absolute. Absolute by default.
function Rect:update_position(dx, dy, relative)
   local x, y = dx, dy
   if relative ~= nil then x, y = self.x + dx, self.y + dy end
   self.x, self.y = x or self.x, y or self.y
   local container = self:get_container()
   if container ~= nil then
      if container then container.x, container.y = self.x, self.y end
      if container.element then container.element.x, container.element.y = self.x, self.y end
   end
end

function Rect:inside(x, y)
   local fx, fy = self.x, self.y
   return (x >= fx and x <= (fx + self.width)) and
          (y >= fy and y <= (fy + self.height))
end

function Rect:on_press(msg)
   if self.draggable then
      self.last_move_pos.mx, self.last_move_pos.my = self:last_move_position()
   end
   self.pressed = true
end

function Rect:on_release(msg)
   self.dt_pressed = 0
   self.pressed = false
   self.dragging = false
end

Rect.event_types = {
   ["mousepressed"] =function(self, msg) self:on_press(msg) end,
   ["touchpressed"] =function(self, msg) self:on_press(msg) end,
   ["mousereleased"]=function(self, msg) self:on_release(msg) end,
   ["touchreleased"]=function(self, msg) self:on_release(msg) end,
   ["hover_end"]    =function(self, msg) self:on_release(msg) end,
   ["hover_cont"]   =function(self, msg) if self.draggable then self:drag(msg) end end,
}

return Rect
