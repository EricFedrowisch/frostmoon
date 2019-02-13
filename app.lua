--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local components = {} --List of components to register to ViewController
------------------------------------------
local bx = function () return (vc.s_width/2)-(res.img["button/button.png"]:getWidth()/2) end
local by = function () return (vc.s_height/2)-(res.img["button/button.png"]:getHeight()/2) end
local button = f:new({
   ["component_type"] = "gui.button",
   ["image"] = res.img["button/button.png"],
   ["image_on_click"] = res.img["button/button_onClick.png"],
   ["x"] = bx(),
   ["y"] = by(),
   ["interact_sound"] = res.snd["Click.mp3"],
   ["resize"] = {bx, by},
})

local tx = function () return (vc.s_width/2) - 50 end
local ty = function () return (vc.s_height/2 - 200) end
local textbox = f:new({
   ["component_type"] = "gui.textbox",
   ["x"] = tx(),
   ["y"] = ty(),
   ["resize"] = {tx, ty},
   ["draggable"] = true,
})

local tooltip = f:new({
   ["component_type"] = "gui.tooltip",
}, button)


components.textbox = textbox
components.button = button
components.tooltip = tooltip

------------------------------------------

return components
