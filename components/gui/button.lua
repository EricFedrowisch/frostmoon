--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["toggleable"] = false,
   ["count"] = 0
}

function Button:push()
   self:change_image()
   self.count = self.count + 1
   print("Count:", self.count)
   print("Button uuid" .. tostring(self._uuid) .. " pushed.")
end

function Button:change_image()
   if self.pressed then
      self.view.image = self.image_on_click
   else
      self.view.image = self.view.image_initial
   end
end

Button.event_types = {
   --MOUSE--
   ["mousepressed"]=function(self, msg) self.pressed = true; self:change_image() end,
   ["mousereleased"]=function(self, msg) self.pressed = false; self:push() end,
   ["mouseover_end"]=function(self, msg) self.pressed = false; self:change_image() end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self.pressed = true; self:change_image() end,
   ["touchreleased"]=function(self, msg) self.pressed = false; self:push() end,
}

function Button:init(new_args)
   local width = new_args.image:getWidth()
   local height = new_args.image:getHeight()
   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = width,
      ["height"] = height,
      ["x"] = new_args.x,
      ["y"] = new_args.y,
   })
   self.view = f:new({
      ["component_type"] = "gui.view",
      ["image"] = res.img["button/button.png"],
      ["x"] = new_args.x,
      ["y"] = new_args.y,
   })
   return self
end

return Button
