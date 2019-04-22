--[[
Element object for storing rendering info
]]
local Element = {}

Element.defaults = {
   ["x"] = 0, --X screen position
   ["y"]= 0,  --Y screen position
   ["z"] = 1, --Z screen position
   ["r"] = 0, --number of radians to rotate image
   ["sre_x"] = 1/8, --Screen real estate on x axis
   ["sre_y"] = 1/8, --Screen real estate on y axis
   ["draw_image"] = true, --Boolean for blitting self.image or calling self.draw
   ["maintain_aspect_ratio"] = true, --Maintain image aspect ratio during resize
   ["visible"] = true,
}

function Element:init(new_args)
   if new_args.image ~= nil then --If initialized with image...
      self.image = new_args.image
      if new_args.image_initial == nil then self.image_initial = self.image end
      self.draw_image = true
      self.image = res.resize(self.image, self.sre_x, self.sre_y, self.maintain_aspect_ratio)
   end
   --If draw function is defined use custom draw function instead of simple image
   if new_args.draw ~= nil then self.draw_image = false end
   --If self.x or self.y are nil, then use container's position
   self.x = self.x or self._container.x
   self.y = self.x or self._container.y
   return self
end

return Element
