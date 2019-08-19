--[[
Scene object for storing a scene of a game/program.
]]
local Scene = {}
Scene.defaults = {
   background_img = nil, --the scene's background image
   hotkey = nil, --The hotkey binding
}

function Scene:init(args)
   if args.background_img ~= nil then make_bg(args.background_img) end
end

--Pass thru function to register objects from scene to ViewController
function Scene:register(obj)
   _G.vc:register(obj, self)
end

function Scene:make_bg(img)
   local bg = Element{
      ["_container"] = self,
      ["background"] = true,
      ["image"]=img,
      ["maintain_aspect_ratio"] = false, --Stretch backgrounds by default
      ["psp_x"] = 1, --Positive space proportion on x axis
      ["psp_y"] = 1, --Positive space proportion on y axis
      ["z"] = 0, --Make background use z layer 0
   }
   _G.vc:register(bg, self) --Register background
end

Scene.event_types = {

}

return Scene
