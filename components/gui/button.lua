--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   --["toggleable"] = false,
   --["draggable"]  = false,
   ["button_function"] = function(self, msg) end, --What to do when pressed
   --["interact_sound"] = nil,
   ["sre_x"] = 1/8, --Screen real estate on x axis
   ["sre_y"] = 1/8, --Screen real estate on y axis
   ["x"] = 0,
   ["y"] = 0,
   ["z"] = 1,
}

function Button:init(new_args)
   local image = self.image or res.img["No-Image.png"] --Initialize image or use default
   local image_on_interact = self.image_on_interact or image --Initialize interact image or use default
   self.image_initial = image --Set self.image_initial to the original sized image
   self.image = _G.res.resize(image, self.sre_x, self.sre_y, self.maintain_aspect_ratio) --Resize image
   self.image_on_interact = _G.res.resize(image_on_interact, self.sre_x, self.sre_y, self.maintain_aspect_ratio)  --Resize interact image
   --First make element, to use it's resize functionality
   self.element = f:new({
      ["image"] = self.image,
      ["component_type"] = "gui.element",
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
      ["sre_x"] = self.sre_x, --Screen real estate on x axis
      ["sre_y"] = self.sre_x, --Screen real estate on y axis
   }, self)
   --Use element's image for rect's height and width
   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = self.element.image:getWidth(),
      ["height"] = self.element.image:getHeight(),
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
      ["draggable"] = self.draggable,
   }, self)
end

function Button:resize()
   self.element.image = _G.res.resize(self.element.image_initial, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   self.rect.width, self.rect.height = self.element.image:getWidth(), self.element.image:getHeight()
   if self.image_on_interact ~= nil then
      self.image_on_interact = _G.res.resize(self.image_on_interact, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   else
      self.image_on_interact = self.element.image --If no interact image, use the main image
   end
end

--Button pressed but not yet released
function Button:hover_press(msg)
   self.pressed = true
   self:change_image()
   msg.handled = 1
end

--Button was pressed but not released. Now its not pressed/hovered over anymore.
function Button:press_over(msg)
   self.pressed = false
   self:change_image()
   msg.handled = 1
end

function Button:push(msg)
   if msg.dt ~= nil then --Prevent "mouse bounce"
      self.pressed = false
      self:change_image()
      if self.interact_sound ~= nil then self.interact_sound:play() end
      if self.button_function ~= nil then self:button_function() end
   end
   msg.handled = 1
end

function Button:change_image()
   if self.pressed then
      self.element.image = self.image_on_interact
   else
      self.element.image = _G.res.resize(self.element.image_initial, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   end
end

Button.event_types = {
   --MOUSE--
   ["mousepressed"]=function(self, msg) self:hover_press(msg) end,
   ["mousereleased"]=function(self, msg) self:push(msg) end,
   ["hover_end"]=function(self, msg) self:press_over(msg) end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self:hover_press(msg) end,
   ["touchreleased"]=function(self, msg) self:push(msg) end,
   --WINDOW
   ["resize"]=function(self, msg) self:resize() end,
}

return Button
