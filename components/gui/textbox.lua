--[[Simple object for storing text to render to screen]]
local Textbox = {}

Textbox.defaults = {
   ["font"] = "default",
   ["align"] = "center", --Valid text alignments include: 'right', 'left' and 'center'
   ["font_size"] = 12,
   ["width"] = 100,
   ["height"] = 100,
   ["x"] = 0,
   ["y"] = 0,
   ["z"] = 1,
   ["text"] = "Hello, World",
   ["padding"] = 0,
   ["text_color"] = {1,0,0,1},
   ["draggable"] = true,
   ["last_mouse_pos"] = {0,0},
}

function Textbox:draw()
   --Init Things needed for Draw
   love.graphics.setColor(unpack(self.text_color))
   love.graphics.setFont(res.fnt[self.font])
   --Draw Wireframe
   love.graphics.rectangle("line", self.x, self.y, self.width, self.height )
   --Draw Text
   love.graphics.printf(self.text, self.x, self.y, self.width, 'center')
   --Reset Phase
   love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
end

function Textbox:last_mouse_position()
   self.last_mouse_pos.mx, self.last_mouse_pos.my = love.mouse.getPosition()
end

function Textbox:drag()
   if self.pressed then
      local mx, my = love.mouse.getPosition()
      --Calculate the change between the last point and the mouse cursor
      local dx = self.rect.x - (self.last_mouse_pos.mx - mx)
      local dy = self.rect.y - (self.last_mouse_pos.my - my)
      self:update_position(dx, dy)
      self:last_mouse_position()
   end
end

--Make a change to postion. Changes are either relative or absolute. Absolute by default.
function Textbox:update_position(dx, dy, relative)
   local x, y = dx, dy
   if relative ~= nil then x, y = self.x + dx, self.y + dy end
   if self.rect then self.rect.x, self.rect.y = x, y end
   if self.view then self.view.x, self.view.y = x, y end
   self.x, self.y = x, y
end

function Textbox:init(new_args)

   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = self.width,
      ["height"] = self.height,
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
   }, self)

   self.view = f:new({
      ["component_type"] = "gui.view",
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
   }, self)

   if new_args.tooltip_text ~= nil then
      local textbox = f:new({
         ["component_type"] = "gui.tooltip",
         ["text"] = new_args.tooltip_text,
      }, self)
   end
   return self
end

Textbox.event_types = {
   --MOUSE--
   ["mousepressed"]=function(self, msg) if self.draggable then self.pressed = true; self:last_mouse_position() end end,
   ["mousereleased"]=function(self, msg) self.pressed = false end,
   ["mouseover_end"]=function(self, msg) self.pressed = false end,
   ["mouseover_cont"]=function(self, msg) self:drag() end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) if self.draggable then self.pressed = true end end,
   ["touchreleased"]=function(self, msg) self.pressed = false end,
}

return Textbox
