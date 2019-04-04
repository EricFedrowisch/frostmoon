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
--_G.vc = f:new({["component_type"] = "gui.viewcontroller"}) --Make new View Controller
_G.res = require "resources" --Load imgs, sounds, video, etc
_G.OS = love.system.getOS() --The current operating system. "OS X", "Windows", "Linux", "Android" or "iOS".
------------------------------------------

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   love.filesystem.load(lib .. "callbacks.lua")() --Load and run the callbacks
   scenes = love.filesystem.load("app.lua")()
   --vc = _G.current_scene.view
   _G.current_scene.view.s_width, _G.current_scene.view.s_height = love.window.getMode()
   love.window.setMode(_G.current_scene.view.s_width, _G.current_scene.view.s_height, {["resizable"] = true})

end

local function draw_touches()
   local touches = love.touch.getTouches()
   for i, id in ipairs(touches) do
      local x, y = love.touch.getPosition(id)
      love.graphics.circle("fill", x, y, 20)
   end
end

--love.draw	Callback function used to draw on the screen every frame.
function love.draw()
   love.graphics.clear(0, 0, 0, 1)
   if _G.OS == "iOS" then draw_touches() end
   _G.current_scene.view:draw()
end

function love.update(dt)
   _G.current_scene.view:update(dt)
   if love.keyboard.isDown("escape") then love.event.quit() end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()
   print("Until we meet again, stay frosty!")
end
