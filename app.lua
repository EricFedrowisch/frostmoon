--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local scenes = {} --List of scenes to register
------------------------------------------
local hotkey = Hotkey{}
local dbg_fx = function () _G.f_debug.draw_debug = not _G.f_debug.draw_debug; print("Draw Debug On:", _G.f_debug.draw_debug) end
local dbg_events = function () _G.f_debug.debug_events = not _G.f_debug.debug_events; print("Event Debug On:", _G.f_debug.debug_events) end
local examine_fx = function ()
   local hover = _G.vc.hover_over
   if hover ~= nil and #hover > 0 then
      for k, i in pairs(hover) do
         f_debug.tprint(i)
         f_debug.line()
      end
   end
end
local key_down_fx = function () print("Key pressed down...") end

local change_scene = function ()
   local scene_id = _G.vc.current_scene.scene_id
   if scene_id ~= 1 then
      _G.vc:change_scene(1)
      if _G.f_debug ~= nil then _G.f_debug.more_info("Change to scene id 1, named " .. _G.vc.current_scene.name) end
    else
      _G.vc:change_scene(2)
      if _G.f_debug ~= nil then _G.f_debug.more_info("Change to scene id 2, named " .. _G.vc.current_scene.name) end
    end
end

love.keyboard.setKeyRepeat(true)
--print("Repeats?:", love.keyboard.hasKeyRepeat())
hotkey:register_key({"d","lctrl"}, dbg_fx); hotkey:register_key({"d","rctrl"}, dbg_fx)
hotkey:register_key({"lshift"}, key_down_fx, true); hotkey:register_key({"rshift"}, key_down_fx, true)
hotkey:register_key({"a"}, key_down_fx, true)
hotkey:register_key({"e"}, dbg_events)
hotkey:register_key({"x"}, examine_fx)
hotkey:register_key({"t"}, change_scene)
hotkey:register_key({"escape"}, love.event.quit)

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
   image = res.img["button/01_c_04.png"],
   px = 1/8,
   py = 1/8,
   button_function = function(self) print("Pressed Button 1") end,
}

local button2 = Button{
   image = res.img["button/01_c_02.png"],
   button_function = function(self) print("Pressed Button 2") end,
   px = 1/4,
   py = 1/4,
   z = 2,
}

local button3 = Button{
   image = res.img["button/01_c_03.png"],
   button_function = function(self) print("Pressed Button 3") end,
   px = 3/8,
   py = 3/8,
   z = 3,
}

local button4 = Button{
   image = res.img["button/01_c_04.png"],
   button_function = function(self, msg)
      print("Screen size: ", love.window.getMode())
      print(self.rect.x,self.rect.y); self.rect:center_on(0.5,0.5); print(self.rect.x,self.rect.y);
   end,
   px = 1/8,
   py = 1/8,
   z = 2,
}

local drag1 = Draggable{
   image = res.img["button/button.png"],
   px = 1/2,
   py = 1/2,
   z = 1
}

local text1 = Textbox{
   px = 1/2,
   py = 1/2,
   psp_x = 1/2,
   psp_y = 1/2
}

love.window.setTitle("FrostMoon Demo")

menu_scene:register(button1)
menu_scene:register(button2)
menu_scene:register(button3)
menu_scene:register(drag1)
scene2:register(button4)
scene2:register(text1)

------------------------------------------
scenes[#scenes + 1] = menu_scene --Make menu_scene the 1st scene
scenes[#scenes + 1] = scene2

--MUST return scene list here as last action.
return scenes
