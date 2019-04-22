--[[
Scene object for storing a scene of a game/program.
]]
local Scene = {}
Scene.defaults = {
   view = nil, --the scene's gui.viewcontroller object, which handles rendering
   background_img = nil, --the scene's background image
}

function Scene:init(new_args)
   if self.vc == nil then
      self.vc = f:new({["component_type"] = "gui.viewcontroller"})
   end
   if new_args.background_img ~= nil then
      local bg = f:new({
         ["component_type"] = "gui.element",
         ["image"]=new_args.background_img,
         ["sre_x"] = 1, --Screen real estate on x axis
         ["sre_y"] = 1, --Screen real estate on y axis
      })

      self.vc:register_element(bg)
   end
   return self
end

--Pass thru function to register objects from scene to ViewController
function Scene:register(obj)
   self.vc:register(obj)
end

Scene.event_types = {

}

return Scene
