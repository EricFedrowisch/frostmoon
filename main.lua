--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
-----------------------------------------
local lib = "" .. package.config:sub(1,1)  .. "lib" .. package.config:sub(1,1)
love.filesystem.setRequirePath(love.filesystem.getRequirePath().. ";" .. lib .. "?.lua")
------------------------------------------
--GLOBALS
--(Löve itself is implicitly in the globals)
_G.os_sep = package.config:sub(1,1)
_G.d = require "f_debug"
_G.f = require "frostmoon"
_G.q = f.queue.new(1000) --Create Event Queue,
_G.res = require "resources" --Load imgs, sounds, video, etc
_G.OS = love.system.getOS() --The current operating system. "OS X", "Windows", "Linux", "Android" or "iOS".
love.filesystem.load(lib .. "callbacks.lua")() --Load and run the callbacks
------------------------------------------
--DEBUG
--Debug Stuff. Remove from production.
_G.debug_modes = {}
_G.debug_modes.draw_debug = false
_G.debug_modes.continuous = false --Whether to run during tests every cycle of main loop.
_G.debug_modes.run_test_countdown = 1 --How many times to run during tests if not continuous
_G.debug_modes.draw_touches = false --Whether to draw touches on touch screens
--DEBUG END

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
   exec("" .. os_sep  .. "tests" .. os_sep .. "pre") --Run autoexec scripts
   _G.vc = ViewController{} --Create ViewController
   _G.vc.s_width, _G.vc.s_height = love.window.getMode()
   love.window.setMode(_G.vc.s_width, _G.vc.s_height, {["resizable"] = true})
   exec("" .. os_sep  .. "autoexec") --Run autoexec scripts
   load_scenes()
end

function load_scenes()
   local scenes = love.filesystem.load("app.lua")()
   for _, scene in pairs(scenes) do
      _G.vc:register_scene(scene)
   end
   _G.vc:change_scene(1) --By default scene 1 is loaded at runtime.
end

--Run lua scripts in given folder
function exec(path)
   for _,v in ipairs(_G.res.get_files(path)) do
      if v:match("[^.]+$") == "lua" then
         print("Running script:", v)
         love.filesystem.load(v)()
      end
   end
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
   love.graphics.setColor(1, 1, 1, 1)
   _G.vc:draw()
   --DEBUG
   if _G.debug_modes.draw_debug == true then _G.vc:draw_debug() end
   --DEBUG END
end

function love.update(dt)
   _G.vc:update(dt)
   --DEBUG
   if _G.debug_modes.continuous or _G.debug_modes.run_test_countdown > 0 then
      _G.debug_modes.run_test_countdown = _G.debug_modes.run_test_countdown - 1
      exec("" .. os_sep  .. "tests" .. os_sep .. "during")
   --DEBUG END
   end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()

   exec("" .. os_sep  .. "tests" .. os_sep .. "post")
   print("Until we meet again, stay frosty!")
end
