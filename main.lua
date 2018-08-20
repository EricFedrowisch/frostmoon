local love = require("love")
--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.

--#TODO:Set lua Environment to avoid namespace collisons
--#TODO:Create a prototype template that allows for components
--#TODO:Cross platform user input code
--#TODO:Cross platform file operatiosn for data persistence and asset loading
--#TODO:Code repo?
--#TODO:View Container
--#TODO:Build some Basic Widgets; button, label, etc
--]]

local f = require"frostmoon"
--for k,v in pairs(f) do print(k,v) end

function love.load()
  math.randomseed(os.time())
  time = 0
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
  time = time + dt
end

function love.draw()
end

function love.quit()
  print("Until we meet again, stay frosty!")
end
