--[[
Draggable component for enabling a rect to be moved by user input.
]]
local Draggable = {}

Draggable.defaults = {
   last_move_pos = {0,0},
   dt_pressed = 0,
   x = 0,
   y = 0,
   z = 1,
   -- px = 0, --Proportionate x value (proportion from the left side of screen)
   -- py = 0, --Proportionate y value (proportion from the top of the screen)
   psp_x = 1/8, --Positive space proportion on x axis
   psp_y = 1/8, --Positive space proportion on y axis
   align = 'center', --Valid px,py alignments include: 'absolute' and 'center'
}

function Draggable:init(args)
   local screen_width, screen_height = love.window.getMode()
   if self.px ~= nil then self.x = self.px * screen_width end --If px supplied use it to find x
   if self.py ~= nil then self.y = self.py * screen_height end --If py supplied use it to find y
   self.element = Element{
      __container = self,
      image = self.image or res.img["No-Image.png"], --Initialize image or use default,
      x =  self.x,
      y = self.y,
      z = self.z,
      psp_x = self.psp_x, --Positive space proportion on x axis
      psp_y = self.psp_x, --Positive space proportion on y axis
   }

   --Use element's rect
   self.rect = self.element.rect
   if self.align == 'center' then self.rect:center_on_xy(self.x, self.y) end
end

function Draggable:last_move_position()
   local dx, dy
   if _G.OS ~= "iOS" then --If you are not mobile then...
      dx, dy = love.mouse.getPosition() --Just get mouse position
   else --Else if mobile then...
      dx, dy = self:get_mobile_touch_pos() --Get mobile touch postion
   end
   return dx, dy
end

function Draggable:get_mobile_touch_pos()
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

function Draggable:drag(msg)
   if self.pressed then
      self.dt_pressed = msg.dt + self.dt_pressed
      if self.dt_pressed >= 0.1 then
         self.dragging = true
      end
      local mx, my = self:last_move_position()
      if mx ~= nil and my ~= nil then
         --Calculate the change between the last point and the mouse cursor
         local dx = self.rect.x - (self.last_move_pos.mx - mx)
         local dy = self.rect.y - (self.last_move_pos.my - my)
         self.rect:update_position(dx, dy)
         self.last_move_pos.mx, self.last_move_pos.my = mx, my
      end
   end
end

function Draggable:on_press(msg)
   self.last_move_pos.mx, self.last_move_pos.my = self:last_move_position()
   self.pressed = true
end

function Draggable:on_release(msg)
   self.dt_pressed = 0
   self.pressed = false
   self.dragging = false
end

Draggable.event_types = {
   hover_cont   = function(self, msg) if self.pressed then self:drag(msg) end end,
   mousepressed = function(self, msg) self:on_press(msg) end,
   touchpressed = function(self, msg) self:on_press(msg) end,
   mousereleased = function(self, msg) self:on_release(msg) end,
   touchreleased = function(self, msg) self:on_release(msg) end,
   mousemoved = function(self, msg) if self.dragging then self.rect:center_on_xy(msg.args.x, msg.args.y) end end,
}

return Draggable
