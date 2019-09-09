--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["button_function"] = function(self, msg) print("DEFAULT BUTTON FUNCTION INVOKED") end, --What to do when pressed
   ["psp_x"] = 1/8, --Positive space proportion on x axis
   ["psp_y"] = 1/8, --Positive space proportion on y axis
   ["x"] = 0,
   ["y"] = 0,
   ["z"] = 1,
   --["toggleable"] = false,
   --["draggable"]  = false,
   --["interact_sound"] = nil,
}

function Button:init(args)
   local image = self.image or res.img["No-Image.png"] --Initialize image or use default
   local image_on_interact = self.interact_image or image --Initialize interact image or use default
   self.image_initial, self.interact_image_initial = image, image_on_interact --Set initial images to the original sized image
   self.image = _G.res.resize(image, self.psp_x, self.psp_y, self.maintain_aspect_ratio) --Resize image
   self.interact_image = _G.res.resize(image_on_interact, self.psp_x, self.psp_y, self.maintain_aspect_ratio)  --Resize interact image
   self.element = Element{

      ["image"] = self.image,
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
      ["psp_x"] = self.psp_x, --Positive space proportion on x axis
      ["psp_y"] = self.psp_x, --Positive space proportion on y axis
   }
   self.element._container = self
   --Use element's image for rect's height and width
   self.rect = Rect{

      ["width"] = self.element.image:getWidth(),
      ["height"] = self.element.image:getHeight(),
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
      ["draggable"] = self.draggable,
   }
   self.rect._container = self
end

function Button:resize()
   self.element.image = _G.res.resize(self.element.image_initial, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
   if self.interact_image ~= nil then
      self.interact_image = _G.res.resize(self.interact_image_initial, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
   else
      self.interact_image = self.element.image --If no interact image, use the main image
   end
   --Update width and height variables
   self.width, self.height = self.element.image:getWidth(), self.element.image:getHeight()
   self.rect:update_size()
end

--Button pressed but not yet released
function Button:hover_press(msg)
   self.pressed = true
   self:change_image()
   self:pass_rect_msg(msg)
end

--Button was pressed but not released. Now its not pressed/hovered over anymore.
function Button:press_over(msg)
   self.pressed = false
   self:change_image()
   self:pass_rect_msg(msg)
end

function Button:release(msg)
   self.pressed = false
   if self.rect.dragging ~= true then
      self:change_image()
      if self.interact_sound ~= nil then self.interact_sound:play() end
      if self.button_function ~= nil then self:button_function() end
   end
   self:pass_rect_msg(msg)
end

function Button:change_image()
   if self.pressed then
      self.element.image = self.interact_image
   else
      self.element.image = _G.res.resize(self.element.image_initial, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
   end
end

function Button:pass_rect_msg(msg)
   self.rect:receive_msg(msg)
   msg.handled = 1
end

Button.event_types = {
   ["mousepressed"]=function(self, msg) self:hover_press(msg) end,
   ["touchpressed"]=function(self, msg) self:hover_press(msg) end,
   ["mousereleased"]=function(self, msg) self:release(msg) end,
   ["touchreleased"]=function(self, msg) self:release(msg) end,
   ["hover_end"]=function(self, msg) self:press_over(msg) end,
   ["hover_cont"]=function(self, msg) self:pass_rect_msg(msg) end,
   ["resize"]=function(self, msg) self:resize() end,
}

return Button
