--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local scenes = {} --List of scenes to register
------------------------------------------
local menus_screen = f:new({
   ["component_type"] = "gui.scene",
   ["view"] = f:new({["component_type"] = "gui.viewcontroller"}),
   --["background" = _G.res.img[""]]
})

--d.tprint(menus_screen)
------------------------------------------
_G.current_scene = menus_screen
scenes.menus_screen = menus_screen
return scenes
