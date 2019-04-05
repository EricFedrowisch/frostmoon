--[[
Scene object for storing a scene of a game/program.
]]
local Scene = {}
Scene.defaults = {
   view = nil,
   background = nil,
}

Scene.event_types = {

}

function Scene:init(new_args)
   if self.view == nil then
      self.view = f:new({["component_type"] = "gui.viewcontroller"})
   end
   if new_args.background ~= nil then
      local bg = f:new({
         ["component_type"] = "gui.element",
         ["image"]=new_args.background,
         ["draw"]=function(self)
            local bg = self.image
            local sx = love.graphics.getWidth()/bg:getWidth()
            local sy = love.graphics.getHeight()/bg:getHeight()
            love.graphics.draw(bg, 0, 0, 0, sx, sy)
            end,
      })

      self.view:register_element(bg)
   end
   return self
end

return Scene
