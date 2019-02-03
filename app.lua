--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local components = {} --List of components to register to ViewController
------------------------------------------

local rect_args = {
   ["component_type"] = "gui.rect",
   ["width"]  = res.img["button/button.png"]:getWidth(),
   ["height"] = res.img["button/button.png"]:getHeight(),
   ["x"] = function () return (vc.s_width/2)-(res.img["button/button.png"]:getWidth()/2) end ,
   ["y"] = function () return (vc.s_height/2)-(res.img["button/button.png"]:getHeight()/2) end,
}
local rect = f:new(rect_args)

local button_view_args = {
   ["component_type"] = "gui.view",
   ["image"] = res.img["button/button.png"],
   ["image_initial"] = res.img["button/button.png"], --Make defualt here
   ["image_on_click"] = res.img["button/button_onClick.png"],
   ["x"] = rect.x,
   ["y"]= rect.y,
   ["width"] = res.img["button/button.png"]:getWidth(),
   ["height"] = res.img["button/button.png"]:getHeight(),
}
local button_view = f:new(button_view_args)

local button = f:new({
   ["component_type"] = "gui.button",
   ["image"] = res.img["button/button.png"],
   ["image_on_click"] = res.img["button/button_onClick.png"],
   ["x"] = function () return (vc.s_width/2)-(res.img["button/button.png"]:getWidth()/2) end ,
   ["y"] = function () return (vc.s_height/2)-(res.img["button/button.png"]:getHeight()/2) end,
})

button["rect"] = rect
button["view"] = button_view

components.button = button
------------------------------------------

return components
