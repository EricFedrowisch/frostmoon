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
   ["maintain_aspect_ratio"] = true, --Maintain image aspect ratio during resize
   ["visible"] = true,
   ["draw"] = function(self) love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy) end,
   ["resize"] = function(self) self.image = _G.res.resize(self.image_initial, self.sre_x, self.sre_y, self.maintain_aspect_ratio) end,
}

function Element:init(new_args)
   local image = self.image or res.img["No-Image.png"]
   self.image_initial = image
   self:resize()
   self.x = self.x or self._container.x
   self.y = self.x or self._container.y
end

return Element
