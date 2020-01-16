--[[
Element object for storing rendering info
]]
local Element = {}

Element.defaults = {
   x = 0, --X screen position
   y = 0,  --Y screen position
   z = 1, --Z screen position
   r = 0, --number of radians to rotate image
   psp_x = 1/8, --Positive space proportion on x axis
   psp_y = 1/8, --Positive space proportion on y axis
   maintain_aspect_ratio = true, --Maintain image aspect ratio during resize
   visible = true,
   draw = Element.draw,
   resize = Element.resize
}

function Element:update_draw(image, x, y , r)
   self.draw = function() love.graphics.draw(image, x, y , r) end
end

function Element:draw()
   love.graphics.draw(self.image, self.rect.x, self.rect.y, self.r)
end

function Element:resize(image)
   if image ~= nil then --If image supplied, resize that and assign it to element
      self.image = _G.res.resize(self.image, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
   else --Else if no image supplied resize and use initial image
      self.image = _G.res.resize(self.image_initial, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
   end
   self.rect:update_size(self.image:getWidth(), self.image:getHeight())
end

function Element:get_absolute_position()
    return self.rect.x, self.rect.y
end

function Element:get_z()
   return self.rect.z
end

function Element:update_absolute_position(x, y, z)
   self.rect.x = x
   self.rect.y = y
   self.rect.z = z
end

function Element:get_rect()
   return self.rect
end

function Element:init(args)
   local image = self.image or res.img["No-Image.png"]
   self.image_initial = image
   self.rect = Rect{
      __container = self,
      width = self.image:getWidth(),
      height = self.image:getHeight(),
      x = self.x,
      y = self.y,
      z = self.z,
   }
   self:resize()
end

Element.event_types = {
   update_position = function(self, msg) self:update_draw(self.image, self.rect.x, self.rect.y, self.r) end,
}

return Element
