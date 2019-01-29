--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--#TODO:GUI layouts; grid, anchor, etc
if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
------------------------------------------
_G.os_sep = package.config:sub(1,1)
local lib = "" .. os_sep  .. "lib" .. os_sep
love.filesystem.setRequirePath(love.filesystem.getRequirePath().. ";" .. lib .. "?.lua")
local f = require "frostmoon"
------------------------------------------
local d = require "frost_debug"
-----------------------------------------
local vc, q; --Declare variables for the ViewController and Queue

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   q = f.queue:new(1000) --Create Event Queue
   local callbacks = love.filesystem.load(lib .. "callbacks.lua")(love, q, vc)
   vc = f:new({["component_type"] = "gui.viewcontroller"}) --Make new View Controller
   vc.love, vc.q = love, q --Why this? Idk. Can't seem to pass in the table of vc args.
   vc.s_width, vc.s_height = love.window.getMode()
   love.window.setMode(vc.s_width, vc.s_height, {["resizable"] = true})
   local app_comps = love.filesystem.load("app.lua")(love, q, vc)
   for k,v in pairs(app_comps) do
      vc:register_obj(v)
   end
end

--love.draw	Callback function used to draw on the screen every frame.
function love.draw()
   vc:draw()
end

function love.update(dt)
   vc:update(dt)
   if love.keyboard.isDown("escape") then love.event.quit() end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()
   print("Until we meet again, stay frosty!")
end
