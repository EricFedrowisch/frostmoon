--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
-----------------------------------------
--GLOBALS
--(Löve itself is implicitly in the globals)
-----------------------------------------
--DEBUG
--Debug Stuff. Remove from production.
_G.debug_modes = {}
_G.debug_modes.more_info = false
_G.debug_modes.draw_debug = false
_G.debug_modes.continuous = false --Whether to run during tests every cycle of main loop.
_G.debug_modes.run_test_countdown = 1 --How many times to run during tests if not continuous
_G.debug_modes.draw_touches = false --Whether to draw touches on touch screens
_G.debug_modes.debug_events = false --Print out event messages
_G.debug_msg_uuids = {}
--DEBUG END
-----------------------------------------
--Operating system info for file system
_G.OS = {}
_G.OS.os_name = love.system.getOS() --The current operating system. "OS X", "Windows", "Linux", "Android" or "iOS".
if _G.OS.os_name ~= "Windows" then
   _G.OS.sep = package.config:sub(1,1) --File system seperator (\ or / usually)
else
   _G.OS.sep = '/'
end
_G.OS.is_fused = love.filesystem.isFused()
_G.OS.cwd = love.filesystem.getWorkingDirectory
_G.OS.source_path = love.filesystem.getSourceBaseDirectory()


--Lookup table for library file paths
local lib_locs = {
   ["OS X"]    = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep,
   ["iOS"]     = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
   ["Windows"] = '/'  .. "lib" .. '/',
   ["Linux"]   = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
   ["Android"] = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
}
_G.OS.lib = lib_locs[_G.OS.os_name] --Set library file path according to OS
--Lookup table for component classes' file paths
local comp_locs = {
   ["OS X"]    = "components",
   ["iOS"]     = "components", --UNTESTED
   ["Windows"] = "components",
   ["Linux"]   = "components", --UNTESTED
   ["Android"] = "components", --UNTESTED
}
--_G.OS.component_dir = comp_locs[_G.OS.os_name] --Set component classes' file path according to OS
_G.OS.component_dir = comp_locs[_G.OS.os_name] --Set component classes' file path according to OS
local reqstr = string.gsub(love.filesystem.getRequirePath() .. ";" .. _G.OS.lib .. "?.lua", '/', '\\')
love.filesystem.setRequirePath(reqstr)
local creqstr =  string.gsub(love.filesystem.getCRequirePath() .. ";" .. _G.OS.lib .. "??", '/', '\\')
love.filesystem.setCRequirePath(creqstr)
_G.OS.require_path = love.filesystem.getRequirePath()
_G.OS.c_require_path = love.filesystem.getCRequirePath()
------------------------------------------
--System Debug Output
if _G.debug_modes.more_info then
   print("OS: " .. _G.OS.os_name)
   print("OS Path Sep: ", _G.OS.sep)
   print("Filesystem fused: " .. tostring(_G.OS.is_fused))
   print("Source Path: ", _G.OS.source_path)
   print("Frostmoon lib files at: " .. _G.OS.lib)
   print("CWD: " .. _G.OS.cwd())
   print("Require path: " .. love.filesystem.getRequirePath())
   print("C Require path: " .. love.filesystem.getCRequirePath())
end
------------------------------------------
_G.d = require "lib.f_debug"
_G.frost_sys = require "lib.frost_sys"
require "lib.frostmoon" --Frostmoon will now be in _G.frostmoon
_G.q = _G.frostmoon.queue.new(1000) --Create Event Queue,
_G.res = require "lib.resources" --Load imgs, sounds, video, etc
love.filesystem.load(_G.OS.lib .. "callbacks.lua")() --Load and run the callbacks
------------------------------------------

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   --if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
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
