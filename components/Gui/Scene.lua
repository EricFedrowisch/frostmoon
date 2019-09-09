--[[
Scene object for storing a scene of a game/program.
]]
local Scene = {}
Scene.defaults = {
   background_img = nil, --the scene's background image
   hotkey = nil, --The hotkey binding
   listeners = {},
   elements = {},
}

function Scene:init(args)
   if args.background_img ~= nil then self:make_bg(args.background_img) end
end

--Register object and internals components recursively.
--Registers all non-element class objects as listeners.
--Registers all element class objects as elements.
function Scene:register(obj)
   self:register_z_index(obj.z) --Make sure lists have correct z
   if obj.component_type ~= "Gui.Element" then --If not element..
      self:register_listener(obj) --Register as listener
   end
   if obj.component_type == "Gui.Element" then --If element
      self:register_element(obj) --Register element
   end
   for k,v in pairs(obj) do --Go through all values of obj...
      if type(v) == "table" then   --if table then check...
         if k ~= "_container" then
            if v.component_type ~= nil then --If component...
               self:register(v)   --Register the component
            end
         end
      end
   end
end

--Given z value, register that z as an index in all the ViewController tables
function Scene:register_z_index(z)
   if z ~= nil then
      if self.listeners[z] == nil then self.listeners[z] = {} end --If entry for z axis coordinate doesn't exist yet, make it
      if self.elements[z] == nil then self.elements[z] = {} end
   end
end

function Scene:register_listener(obj) --Adds object that listens for events
   local z = obj.z or 1
   self.listeners[z][#self.listeners[z]+1] = obj --Add object to listeners in next slot
end

function Scene:register_element(obj) --Adds object that has a on-screen drawn image
   local z = obj.z or 1
   self.elements[z][#self.elements[z]+1] = obj --Add object to elements
end

function Scene:make_bg(img)
   local bg = Element{
      ["background"] = true,
      ["image"]=img,
      ["maintain_aspect_ratio"] = false, --Stretch backgrounds by default
      ["psp_x"] = 1, --Positive space proportion on x axis
      ["psp_y"] = 1, --Positive space proportion on y axis
      ["z"] = 0, --Make background use z layer 0
   }
   self:register(bg) --Register background
end

Scene.event_types = {

}

return Scene
