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

function Element:draw()
   local x,y = self:get_pos()
   love.graphics.draw(self.image, x, y, self.r)
end

function Element:resize()
   self.image = _G.res.resize(self.image_initial, self.psp_x, self.psp_y, self.maintain_aspect_ratio)
end

function Element:get_pos()
    return self.rect.x, self.rect.y
end

function Element:get_z()
   return (self.rect.z)
end

function Element:update_pos(x, y, z)
   self.rect.x = x
   self.rect.y = y
   self.rect.z = z
end


function Element:init(args)
   local image = self.image or res.img["No-Image.png"]
   self.image_initial = image
   self:resize()
   self.rect = Rect{
      __container = self,
      width = self.image:getWidth(),
      height = self.image:getHeight(),
      x = self.x,
      y = self.y,
      z = self.z,
   }
end

return Element
