--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--#TODO:GUI layouts; grid, anchor, etc
if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
-----------------------------------------
local lib = "" .. package.config:sub(1,1)  .. "lib" .. package.config:sub(1,1)
love.filesystem.setRequirePath(love.filesystem.getRequirePath().. ";" .. lib .. "?.lua")
------------------------------------------
--GLOBALS
--(Love itself is implicitly in the globals)
_G.os_sep = package.config:sub(1,1)
_G.d = require "frost_debug"
_G.f = require "frostmoon"
_G.q = f.queue:new(1000) --Create Event Queue,
_G.vc = f:new({["component_type"] = "gui.viewcontroller"}) --Make new View Controller
_G.res = require "resources" --Load imgs, sounds, video, etc
------------------------------------------

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   love.filesystem.load(lib .. "callbacks.lua")() --Load and run the callbacks
   vc.s_width, vc.s_height = love.window.getMode()
   love.window.setMode(vc.s_width, vc.s_height, {["resizable"] = true})
   local app_components = love.filesystem.load("app.lua")()
   for k,v in pairs(app_components) do vc:register_obj(v) end
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
