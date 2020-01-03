--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
-----------------------------------------
--GLOBALS
--(Löve itself is implicitly in the globals)
------------------------------------------
require "lib.frostmoon" --FrostMoon will now be in _G.frostmoon
require "lib.resources" --Load imgs, sounds, video, etc
------------------------------------------
--Optionally:
require "lib.f_debug" --Comment out if you want to disable all debug functionality and tests (for production code)

------------------------------------------
--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   --if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
   exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "pre") --Run pre test scripts
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
         if _G.f_debug ~= nil then _G.f_debug.more_info("Running script: " .. v) end
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
   if _G.f_debug ~= nil then if _G.f_debug.draw_debug == true then _G.vc:draw_debug() end end --DEBUG
end

function love.update(dt)
   _G.vc:update(dt)
   if _G.f_debug ~= nil then _G.f_debug.during() end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()
   exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "post") --Run post test scripts
   print("Until we meet again, stay frosty!")
end
