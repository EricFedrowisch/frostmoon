--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--#TODO:GUI layouts; grid, anchor, etc
if package.config:sub(1,1) == "/" then os.execute("clear") end --Clear terminal output of Unix-like OS
local debug = require "debug"


local f = require "frostmoon"
local d = require "frost_debug"
local queue = require "frost_queue"
local adapter = f:new({["component_type"] = "gui.loveadapter"}) --Make new Adapter
adapter:receive_msg({["type"] = "init", ["love"] = love}) --Init Adapter with löve instance
local q = queue:new(1000)
assert(loadfile("callbacks.lua"))(q, love)

function test()
   --local get_var = adapter:receive_msg({["type"] = "get_var", ["var"] = "_os"})
   --print(get_var)
   --local width, height = love.graphics.getDimensions()
   --print("Window width, height? Love says: ", width, height)
   --local fm_width, fm_height = unpack(adapter:receive_msg({["type"] = "graphics.getDimensions"}))
   --print("Window width, height? Frost says: ", fm_width, fm_height)
   --local adapter_uuid = adapter._uuid
   --local set_clip = {["type"] = "system.setClipboardText", ["args"] = {"HEY! IT WORKED!"}}
   --local other = f:new({["component_type"]="data.object"})
   --other:uuid_msg(adapter_uuid, set_clip)
   --adapter:receive_msg(set_clip)
   --d.tprint(q)
   --local keys = {}
   --for k in pairs(adapter.event_types) do table.insert(keys, k) end
   --table.sort(keys)
   --d.vprint(keys)
   --print("love")
   --d.tprint(love)
end

--love.load	This function is called exactly once at the beginning of the game.
function love.load()
   test()

   --q:add({["type"]="love_load"})
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



--love.draw	Callback function used to draw on the screen every frame.
function love.draw()
end


--love.run	The main function, containing the main loop.
function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

--love.quit	Callback function triggered when the game is closed.
function love.quit()
   print("Until we meet again, stay frosty!")
   d.tprint(q)
end
