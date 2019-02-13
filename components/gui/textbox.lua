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
   ["last_mouse_pos"] = {},
}

function Textbox:draw()
   love.graphics.setColor(unpack(self.text_color))
   love.graphics.setFont(res.fnt[self.font])

   love.graphics.rectangle("line", self.x, self.y, self.width, self.height )

   --love.graphics.printf( text, x, y, limit, align )
   love.graphics.printf(self.text, self.x, self.y, self.width, 'center')
   love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
end

--Get mouse position over self and fix that point as the fixed point of reference
--for drag motions
function Textbox:last_mouse_position()
   self.last_mouse_pos.mx, self.last_mouse_pos.my = love.mouse.getPosition()
end

function Textbox:drag()
   if self.pressed then
      local mx, my = love.mouse.getPosition()
      --Shift the rect by the change between the fix point and the mouse cursor
      self.rect.x = self.rect.x - (self.last_mouse_pos.mx - mx)
      self.rect.y = self.rect.y - (self.last_mouse_pos.my - my)
      --Update fixed drag point to be the current mouse cursor
      self.last_mouse_pos.mx, self.last_mouse_pos.my = mx, my
      --Update View based on Rect
      self.view.x, self.view.y = self.rect.x, self.rect.y
      --Update self as well...
      self.x, self.y = self.rect.x, self.rect.y
      self:last_mouse_position()
   end
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
   ["mousepressed"]=function(self, msg) self.pressed = true; self:last_mouse_position() end,
   ["mousereleased"]=function(self, msg) self.pressed = false end,
   ["mouseover_end"]=function(self, msg) self.pressed = false end,
   ["mouseover_cont"]=function(self, msg) self:drag() end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self.pressed = true end,
   ["touchreleased"]=function(self, msg) self.pressed = false end,
}

return Textbox
