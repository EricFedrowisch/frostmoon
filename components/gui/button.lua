--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["toggleable"]=false,
}
--["image_initial"] = button_img1,
--["image_on_click"] = button_img_onClick,
function Button:push()
   self:change_image()
   print("Button uuid" .. tostring(self._uuid) .. " pushed.")
end

function Button:change_image()
   if self.pressed then
      self.view.image = self.view.image_on_click
   else
      self.view.image = self.view.image_initial
   end
end

Button.event_types = {
   ["mousepressed"]=function(self, msg) self.pressed = true; self:change_image() end,
   ["mousereleased"]=function(self, msg) self.pressed = false; self:push() end,
   ["mouseover_end"]=function(self, msg) self.pressed = false; self:change_image() end,
   ["push"]=function(self, msg)  end,
}

return Button
