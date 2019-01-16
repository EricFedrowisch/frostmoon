if package.config:sub(1,1) == "/" then os.execute("clear") end
--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.

--#TODO:Containers layouts; grid, anchor, etc
--#TODO:Build some Basic Widgets; button, label, etc
--]]

local f = require "frostmoon"
local d = require "frost_debug"
local vc = nil
local adapter = f:new({["component_type"] = "gui.loveadapter"}) --Make new Adapter
adapter:receive_msg({["type"] = "init", ["love"] = love}) --Init Adapter with löve instance

function test()
   local get_var = adapter:receive_msg({["type"] = "get_var", ["var"] = "_os"})
   print(get_var)
   local width, height = love.graphics.getDimensions()
   print("Window width, height? Love says: ", width, height)
   local fm_width, fm_height = unpack(adapter:receive_msg({["type"] = "graphics.getDimensions"}))
   print("Window width, height? Frost says: ", fm_width, fm_height)

   --d.tprint(adapter.event_types)
end

function love.load()
   test()
   --print("love")
   --d.tprint(love)

   --image = love.graphics.newImage("Lua-logo.png")
   --love.graphics.setNewFont(24)
   --love.graphics.setColor(0,0,0)
   --love.graphics.setBackgroundColor(255,255,255)
   --love.window.setMode( width, height)
end

function love.update(dt)
   if love.keyboard.isDown("escape") then
      love.event.quit()
   end
end

function love.draw()
end

function love.quit()
   print("Until we meet again, stay frosty!")
   --os.exit()
end
