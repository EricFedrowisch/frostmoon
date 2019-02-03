--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local components = {} --List of components to register to ViewController
------------------------------------------

local button = f:new({
   ["component_type"] = "gui.button",
   ["image"] = res.img["button/button.png"],
   ["image_on_click"] = res.img["button/button_onClick.png"],
   ["x"] = function () return (vc.s_width/2)-(res.img["button/button.png"]:getWidth()/2) end ,
   ["y"] = function () return (vc.s_height/2)-(res.img["button/button.png"]:getHeight()/2) end,
})

components.button = button
------------------------------------------

return components
