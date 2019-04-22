--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["toggleable"] = false,
   ["draggable"]  = false,
   ["button_function"] = function(self, msg) end, --What to do when pressed
   ["interact_sound"] = nil,
   ["sre_x"] = 1/8, --Screen real estate on x axis
   ["sre_y"] = 1/8, --Screen real estate on y axis
}

function Button:init(new_args)
   local image = new_args.image or res.img["No-Image.png"]
   self.image_initial = image
   local width = image:getWidth()
   local height = image:getHeight()

   self.element = f:new({
      ["component_type"] = "gui.element",
      ["image"] = image,
      ["x"] = self.x,
      ["y"] = self.y,
      ["sre_x"] = self.sre_x, --Screen real estate on x axis
      ["sre_y"] = self.sre_x, --Screen real estate on y axis
   }, self)

   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = width,
      ["height"] = height,
      ["x"] = self.x,
      ["y"] = self.y,
      ["draggable"] = self.draggable,
   }, self)
   return self
end

function Button:resize()
   self.element.image = _G.res.resize(self.element.image, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   self.rect.width, self.rect.height = self.element.image:getWidth(), self.element.image:getHeight()
   if self.image_on_click ~= nil then
      self.image_on_click = _G.res.resize(self.image_on_click, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   end
end

function Button:push(dt)
   if msg.dt ~= nil then --Prevent "mouse bounce"
      self:change_image()
      if self.interact_sound ~= nil then self.interact_sound:play() end
      if self.button_function ~= nil then self:button_function() end
   end
end

function Button:change_image()
   if self.pressed then
      self.element.image = self.image_on_click
   else
      --self.element.image = self.element.image_initial
   end
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
   ["resize"]=function(self, msg) self:resize() end,
}

return Button
