--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------

img = "" .. os_sep  .. "img" .. os_sep --Image folder
local components = {} --List of components to register to ViewController
------------------------------------------

local button_img = love.graphics.newImage(img .. "1stButton.png")
local button_img_onClick = love.graphics.newImage(img .. "1st_Button_Darken_OnClick.png")

local rect_args = {
   ["component_type"] = "gui.rect",
   ["width"] = button_img:getWidth(),
   ["height"] = button_img:getHeight(),
   ["x"] = function () return (vc.s_width/2)-(button_img:getWidth()/2) end ,
   ["y"] = function () return (vc.s_height/2)-(button_img:getHeight()/2) end,
}

local rect = f:new(rect_args)
local button_view_args = {
   ["component_type"] = "gui.view",
   ["image"] = button_img,
   ["image_initial"] = button_img,
   ["image_on_click"] = button_img_onClick,
   ["x"] = rect.x,
   ["y"]= rect.y,
   ["z"] = rect.z,
   ["width"] = button_img:getWidth(),
   ["height"] = button_img:getHeight(),
}

local button_view = f:new(button_view_args)
local button = f:new({["component_type"] = "gui.button", ["image"] = "1stButton.png"})
button["rect"] = rect
button["view"] = button_view

components.button = button
------------------------------------------

return components
