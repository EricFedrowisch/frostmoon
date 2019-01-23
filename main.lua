--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--#TODO:GUI layouts; grid, anchor, etc
if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS

local f = require "frostmoon"
local d = require "frost_debug"
local queue = require "frost_queue"
local vc, adapter, q;
q = queue:new(1000)
assert(loadfile("callbacks.lua"))(q, love)
assert(loadfile("gen_callbacks.lua"))(q, love)

function love.update(dt)
   vc:update()
   if love.keyboard.isDown("escape") then love.event.quit() end
end

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   local s_width, s_height = love.window.getMode()
   love.window.setMode(s_width, s_height, {["resizable"] = true})
   adapter = f:new({["component_type"] = "gui.loveadapter"}) --Make new Adapter
   vc = f:new({ --Make new View Controller
     ["component_type"] = "gui.viewcontroller",
     ["listeners"] = {},
     })
   vc.love = love
   vc.q = q --Why this? Idk. Can't seem to pass in table of vc args.
   local button_img = love.graphics.newImage("1stButton.png")
   local button_img_onClick = love.graphics.newImage("1st_Button_Darken_OnClick.png")

   local rect_args = {
      ["component_type"] = "gui.rect",
      ["width"] = button_img:getWidth(),
      ["height"] = button_img:getHeight(),
      ["x"] = (s_width/2)-(button_img:getWidth()/2),
      ["y"] = (s_height/2)-(button_img:getHeight()/2),
   }
   local rect = f:new(rect_args)
   local button_view_args = {
      ["component_type"] = "gui.view",
      ["image"] = button_img,
      ["image_initial"] = button_img,
      ["image_on_click"] = button_img_onClick,
      ["x"] = rect["x"],
      ["y"]= rect["y"],
      ["z"] = rect["z"],
      ["width"] = button_img:getWidth(),
      ["height"] = button_img:getHeight(),
   }
   local button_view = f:new(button_view_args)
   local button = f:new({["component_type"] = "gui.button"})
   button["rect"] = rect
   button["view"] = button_view
   vc:register_obj(button)

   --image = love.graphics.newImage("Lua-logo.png")
   --love.graphics.setNewFont(24)
   --love.graphics.setColor(0,0,0)
   --love.graphics.setBackgroundColor(255,255,255)
   --love.window.setMode( width, height)
end

--love.draw	Callback function used to draw on the screen every frame.
function love.draw()
   vc:draw()
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()
   print("Until we meet again, stay frosty!")
   vc.love = nil
   vc.q = nil
   d.tprint(vc)
end
