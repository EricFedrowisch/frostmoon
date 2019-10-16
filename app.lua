--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local scenes = {} --List of scenes to register
------------------------------------------
local hotkey = Hotkey{}
local dbg_fx = function () _G.debug_modes.draw_debug = not _G.debug_modes.draw_debug; print("Draw Debug On:", _G.debug_modes.draw_debug) end
local dbg_events = function () _G.debug_modes.debug_events = not _G.debug_modes.debug_events; print("Event Debug On:", _G.debug_modes.debug_events) end
local examine_fx = function ()
   local hover = _G.vc.hover_over
   if hover ~= nil and #hover > 0 then
      for k, i in pairs(hover) do
         d.tprint(i)
         d.line()
      end
   end
end

local change_scene = function ()
   local scene_id = _G.vc.current_scene.scene_id
   if scene_id ~= 1 then
      _G.vc:change_scene(1)
      if _G.debug_modes.more_info then print("Change to scene id 1, named " .. _G.vc.current_scene.name) end
    else
      _G.vc:change_scene(2)
      if _G.debug_modes.more_info then print("Change to scene id 2, named " .. _G.vc.current_scene.name) end
    end
end

hotkey:register_key("d", dbg_fx, "lshift"); hotkey:register_key("d", dbg_fx, "rshift")
hotkey:register_key("e", dbg_events)
hotkey:register_key("x", examine_fx)
hotkey:register_key("c", d.clear)
hotkey:register_key("t", change_scene)
hotkey:register_key("escape", love.event.quit)

local menu_scene = Scene{
   name = "Start Scene",
   background_img = _G.res.img["backgrounds/forest.png"],
   hotkey = hotkey,
}

local scene2 = Scene{
   name = "Second Scene",
   --background_img = _G.res.img["backgrounds/forest.png"],
   hotkey = hotkey,
}

local button1 = Button{
   button_function = function(self, msg) print("Pressed Button 1") end
}

local button2 = Button{
   button_function = function(self, msg) print("Pressed Button 2") end,
   x = button1.element.image:getWidth()/2,
   y = button1.element.image:getHeight()/2,
   z = 2,
}

local button3 = Button{
   button_function = function(self, msg) print("Pressed Button 3") end,
   x = button1.element.image:getWidth(),
   y = button1.element.image:getHeight(),
   z = 3,
}

local button4 = Button{
   button_function = function(self, msg) print("Pressed Button 4") end,
   x = button1.element.image:getWidth() * 1.5,
   y = button1.element.image:getHeight() * 1.5,
   z = 4,
   draggable = true,
}

local button5 = Button{
   button_function = function(self, msg) print("Pressed Button 5") end,
   x = button1.element.image:getWidth() * 2.5,
   y = button1.element.image:getHeight() * 2.5,
   z = 1,
   draggable = true,
}


menu_scene:register(button1)
menu_scene:register(button2)
menu_scene:register(button3)
menu_scene:register(button4)
scene2:register(button5)

------------------------------------------
scenes[#scenes + 1] = menu_scene --Make menu_scene the 1st scene
scenes[#scenes + 1] = scene2

--MUST return scene list here as last action.
return scenes
