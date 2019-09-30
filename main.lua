--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
-----------------------------------------
--DEBUG
--Debug Stuff. Remove from production.
_G.debug_modes = {}
_G.debug_modes.more_info = false
_G.debug_modes.draw_debug = false
_G.debug_modes.continuous = false --Whether to run during tests every cycle of main loop.
_G.debug_modes.run_test_countdown = 1 --How many times to run during tests if not continuous
_G.debug_modes.draw_touches = false --Whether to draw touches on touch screens
--DEBUG END
-----------------------------------------
--Store Operating system info for file system
_G.OS = {}
_G.OS.sep = package.config:sub(1,1)
_G.OS.os_name = love.system.getOS()
_G.OS.is_fused = love.filesystem.isFused()
_G.OS.lib = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep --The current operating system. "OS X", "Windows", "Linux", "Android" or "iOS".
love.filesystem.setRequirePath(love.filesystem.getRequirePath().. ";" .. _G.OS.lib .. "?.lua")
------------------------------------------
--System Debug Output
if _G.debug_modes.more_info then
   print("OS: " .. _G.OS.os_name)
   print("Filesystem fused: " .. tostring(_G.OS.is_fused))
   print("Frostmoon lib files at: " .. _G.OS.lib)
end
------------------------------------------
--GLOBALS
--(Löve itself is implicitly in the globals)
_G.d = require "f_debug"
_G.f = require "frostmoon"
_G.q = f.queue.new(1000) --Create Event Queue,
_G.res = require "resources" --Load imgs, sounds, video, etc
love.filesystem.load(_G.OS.lib .. "callbacks.lua")() --Load and run the callbacks
------------------------------------------

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
   exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "pre") --Run autoexec scripts
   _G.vc = ViewController{} --Create ViewController
   _G.vc.s_width, _G.vc.s_height = love.window.getMode()
   love.window.setMode(_G.vc.s_width, _G.vc.s_height, {["resizable"] = true})
   exec("" .. _G.OS.sep  .. "autoexec") --Run autoexec scripts
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
         if _G.debug_modes.more_info then print("Running script:", v) end
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
      exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "during")
   --DEBUG END
   end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()

   exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "post")
   print("Until we meet again, stay frosty!")
end
