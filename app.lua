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

--d.tprint(menu_screen)
------------------------------------------
_G.current_scene = menu_screen
scenes.menu_screen = menu_screen
return scenes
