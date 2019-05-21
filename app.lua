--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local scenes = {} --List of scenes to register
------------------------------------------
local menu_screen = f:new({
   ["component_type"] = "gui.scene",
   ["background_img"] = _G.res.img["backgrounds/forest.png"],
})

local button = f:new({
   ["component_type"] = "gui.button",
   ["button_function"] = function(self, msg) print("Pressed Button 1") end
})

local button2 = f:new({
   ["component_type"] = "gui.button",
   ["button_function"] = function(self, msg) print("Pressed Button 2") end,
   ["x"] = button.element.image:getWidth()/2,
   ["y"] = button.element.image:getHeight()/2,
   ["z"] = 2,
})

local button3 = f:new({
   ["component_type"] = "gui.button",
   ["button_function"] = function(self, msg) print("Pressed Button 3") end,
   ["x"] = button.element.image:getWidth(),
   ["y"] = button.element.image:getHeight(),
   ["z"] = 3,
})

local button4 = f:new({
   ["component_type"] = "gui.button",
   ["button_function"] = function(self, msg) print("Pressed Button 4") end,
   ["x"] = button.element.image:getWidth() * 1.5,
   ["y"] = button.element.image:getHeight() * 1.5,
   ["z"] = 4,
})

menu_screen:register(button)
menu_screen:register(button2)
menu_screen:register(button3)
menu_screen:register(button4)


--d.tprint(menu_screen)
------------------------------------------
_G.current_scene = menu_screen
scenes.menu_screen = menu_screen
return scenes
