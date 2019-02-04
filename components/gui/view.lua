--[[
View object for storing rendering info
]]
local View = {}

View.defaults = {
   ["x"] = 0,
   ["y"]= 0,
   ["z"] = 1,
   ["is_image"] = false,
   ["width"] = 100,
   ["height"] = 100,
   ["r"] = 0,
}

function View:init(new_args)
   if new_args.image ~= nil then
      self.image = new_args.image
      if new_args.image_initial == nil then self.image_initial = self.image end
      self.is_image = true
      self.width  = self.image:getWidth()
      self.height = self.image:getHeight()
   else
      self.draw = function () self._container:draw() end
      self.x = self._container.x
      self.y = self._container.y
   end
   return self
end

return View
