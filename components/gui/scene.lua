--[[
Scene object for storing a scene of a game/program.
]]
local Scene = {}
Scene.defaults = {
   view = nil, --the scene's gui.viewcontroller object, which handles rendering
   background_img = nil, --the scene's background image
   hotkey = nil, --The hotkey binding
}

function Scene:init(new_args)
   if self.vc == nil then --If no ViewController given, then make one
      self.vc = f:new({["component_type"] = "gui.viewcontroller"})
   end
   if self.hotkey == nil then --If no hotkey handler given, then make one
      self.hotkey = f:new({["component_type"] = "gui.hotkey"})
   end
   self.vc:register_listener(self.hotkey) --Register hotkey handler to ViewController
   if new_args.background_img ~= nil then
      local bg = f:new({
         ["component_type"] = "gui.element",
         ["image"]=new_args.background_img,
         ["maintain_aspect_ratio"] = false, --Stretch backgrounds by default
         ["psp_x"] = 1, --Positive space proportion on x axis
         ["psp_y"] = 1, --Positive space proportion on y axis
         ["z"] = 0, --Make background use background z layer 0
      })
   self.vc:register(bg) --Register background
   end
end

--Pass thru function to register objects from scene to ViewController
function Scene:register(obj)
   self.vc:register(obj)
end

Scene.event_types = {

}

return Scene
