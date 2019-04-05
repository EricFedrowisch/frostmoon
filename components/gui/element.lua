--[[
Element object for storing rendering info
]]
local Element = {}

Element.defaults = {
   ["x"] = 0,
   ["y"]= 0,
   ["z"] = 1,
   ["is_image"] = false,
   ["width"] = 100,
   ["height"] = 100,
   ["r"] = 0,
}

function Element:init(new_args)
   if new_args.image ~= nil then
      self.image = new_args.image
      if new_args.image_initial == nil then self.image_initial = self.image end
      self.is_image = true
      self.width  = self.image:getWidth()
      self.height = self.image:getHeight()
   end
   if new_args.draw == nil then --#TODO: Is this a good idea?
      self.draw = function () self._container:draw() end
   else
      self.is_image = false --May have image but uses custom draw function
   end
   self.x = self.x or self._container.x
   self.y = self.x or self._container.y
   return self
end

return Element
