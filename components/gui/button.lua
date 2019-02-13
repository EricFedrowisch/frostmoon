--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["toggleable"] = false,
}

function Button:push(dt)
   if msg.dt ~= nil then --Prevent "mouse bounce"
      self:change_image()
      if self.interact_sound ~= nil then self.interact_sound:play() end
      if self.button_function ~= nil then self:button_function() end
   end
end

function Button:change_image()
   if self.pressed then
      self.view.image = self.image_on_click
   else
      self.view.image = self.view.image_initial
   end
end

--Make a change to postion. Changes are either relative or absolute. Absolute by default.
function Button:update_position(dx, dy, relative)
   local x, y = dx, dy
   if relative ~= nil then x, y = self.x + dx, self.y + dy end
   if self.rect then self.rect.x, self.rect.y = x, y end
   if self.view then self.view.x, self.view.y = x, y end
   self.x, self.y = x, y
end

function Button:init(new_args)
   local width = new_args.image:getWidth()
   local height = new_args.image:getHeight()
   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = width,
      ["height"] = height,
      ["x"] = new_args.x,
      ["y"] = new_args.y,
   }, self)

   self.view = f:new({
      ["component_type"] = "gui.view",
      ["image"] = res.img["button/button.png"],
      ["x"] = new_args.x,
      ["y"] = new_args.y,
   }, self)

   return self
end

Button.event_types = {
   --MOUSE--
   ["mousepressed"]=function(self, msg) self.pressed = true; self:change_image() end,
   ["mousereleased"]=function(self, msg) self.pressed = false; self:push(msg.dt) end,
   ["mouseover_end"]=function(self, msg) self.pressed = false; self:change_image() end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self.pressed = true; self:change_image(msg.dt) end,
   ["touchreleased"]=function(self, msg) self.pressed = false; self:push() end,
   --WINDOW
   ["resize"]=function(self, msg) self:update_position(self.resize[1](),self.resize[2]())end,
}

return Button
