--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local d = require("frost_debug")
local lfs = require("lfs")
local cwd = lfs.currentdir()
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local args = {...} --Get arguments passed when this module is loaded
local q = args[1] --The main Queue object from main.lua
local love = args[2] --The main Löve table from main.lua
local lines = {} --Table to hold lines of source code
local shell_source = cwd .. os_sep.. "callbacks.lua" --Path to source file for function shell defs
for line in io.lines(shell_source) do table.insert(lines, line) end --Get source
local out = cwd .. os_sep.. "gen_callbacks.lua"
os.execute('rm ' .. cwd .. os_sep.. 'gen_callbacks.lua') --Dont forget to delete/comment or make multi-os

-- Write a string to a file. Filename should be full path and file name. Mode is
--optional parameter for how to write. Default is append.
function write(filename, string, mode)
   local mode = mode or "ab"
   local fh = assert(io.open(filename, mode))
   fh:write(string)
   fh:flush()
   fh:close()
end

--Parse single line function def to return function name and a list of parameter names.
local function parse_def(line)
   local f_args = {}
   local sub = line:sub(line:find('%(')+1, line:find('%)')-1) --Find the sub string between the ()
   f_args[1] = string.gmatch(line, '%.(%a+)%s-%(' )() --Find the name of the function in string line
   for arg in string.gmatch(sub,'%,-(%a+)%,-' ) do f_args[#f_args+1]=arg end --Find the parameter names
   return f_args
end

--Make a generic callback that wraps the Löve callback and sends the arguments
--from that to the Frostmoon Queue as a message.
local function make_generic_callback(f)
   local info = debug.getinfo(f, 'nSL') --Get function info
   local def = tostring(lines[info.linedefined]) --Get function def
   local f_args = {}
   if info ~= nil then
      if info.linedefined == info.lastlinedefined then --Should be a shell
         f_args = parse_def(lines[info.linedefined]) --Parse source line for arg names
         def = def:gsub("end","\n")
         write(out, lines[info.linedefined-1] .. '\n') --Write out comment
         write(out, def)
         write(out, "    msg = {\n")
         write(out, "        [\"type\"] = " .. '"' .. f_args[1] .. '"' .. ",\n")
         write(out, "        [\"args\"] = {\n        ")
         for k,v in pairs(f_args) do
            if k > 1 then
               write(out, "    [\""..v.."\"] = ".. v)
               if k ~= #f_args then write(out, ",\n        ") end
            end
         end
         write(out, "\n        }\n")
         write(out, "    }\n")
         write(out, "    q:add(msg)\n")
         write(out, "end\n\n")
      end
   end

end

------------------------------------------
--Shell Function declarations.
--WINDOW--
--Callback function triggered when window receives or loses focus.
function love.focus(focus) end
--Called when the window is resized
function love.resize(w, h) end
--Callback function triggered when window is minimized/hidden or unminimized by the user.
function love.visible(visible) end
--Callback function triggered when a file is dragged and dropped onto the window.
function love.filedropped(file) end
--Callback function triggered when a directory is dragged and dropped onto the window.
function love.directorydropped(path) end

--MOUSE--
--Callback function triggered when window receives or loses mouse focus.
function love.mousefocus(focus) end
--Callback function triggered when the mouse is moved.
function love.mousemoved(x, y, dx, dy, istouch) end
--Callback function triggered when a mouse button is pressed.
function love.mousepressed(x, y, button, istouch, presses) end
--Callback function triggered when a mouse button is released.
function love.mousereleased(x, y, button, istouch, presses) end
--Callback function triggered when the mouse wheel is moved.
function love.wheelmoved(x, y) end

--KEYBOARD--
--Callback function triggered when a key is pressed.
function love.keypressed(key, scancode, isrepeat) end
--Callback function triggered when a keyboard key is released.
function love.keyreleased(key, scancode) end

--MOBILE--
--Called when the device display orientation changed.
function love.displayrotated(index, orientation) end
--Callback function triggered when a touch press moves inside the touch screen.
function love.touchmoved(id, x, y, dx, dy, pressure) end
--Callback function triggered when the touch screen is touched.
function love.touchpressed(id, x, y, dx, dy, pressure) end
--Callback function triggered when the touch screen stops being touched.
function love.touchreleased(id, x, y, dx, dy, pressure) end
--Callback function triggered when the system is running out of memory on mobile devices.
function love.lowmemory() end

--JOYSTICK--
--Called when a Joystick's virtual gamepad axis is moved.
function love.gamepadaxis(joystick, axis, value) end
--Called when a Joystick's virtual gamepad button is pressed.
function love.gamepadpressed(joystick, button) end
--Called when a Joystick's virtual gamepad button is released.
function love.gamepadreleased(joystick, button) end
--Called when a Joystick is connected.
function love.joystickadded(joystick) end
--Called when a Joystick is disconnected.
function love.joystickremoved(joystick) end
--Called when a joystick axis moves.
function love.joystickaxis(joystick, axis, value) end
--Called when a joystick hat direction changes.
function love.joystickhat(joystick, hat, direction) end
--Called when a joystick button is pressed.
function love.joystickpressed(joystick, button) end
--Called when a joystick button is released.
function love.joystickreleased(joystick, button) end

--MISC--
--Callback function triggered when a Thread encounters an error.
function love.threaderror(thread, errorstr) end
--Called when the candidate text for an IME (Input Method Editor) has changed.
function love.textedited(text, start, length) end
--Called when text has been entered by the user.
function love.textinput(text) end


------------------------------------------
--These functions have defaults set by Löve. Not sure I want to override them rn.
--The error handler, used to display error messages.
--function love.errhand(msg) end
--The error handler, used to display error messages.
--function love.errorhandler(msg) end

------------------------------------------
local function_names = {
   --WINDOW--
   love.focus,
   love.resize,
   love.visible,
   love.filedropped,
   love.directorydropped,
   --MOUSE--
   love.mousefocus,
   love.mousemoved,
   love.mousepressed,
   love.mousereleased,
   love.wheelmoved,
   --KEYBOARD--
   love.keypressed,
   love.keyreleased,
   --MOBILE--
   love.displayrotated,
   love.touchmoved,
   love.touchpressed,
   love.touchreleased,
   love.lowmemory,
   --JOYSTICK--
   love.gamepadaxis,
   love.gamepadpressed,
   love.gamepadreleased,
   love.joystickadded,
   love.joystickremoved,
   love.joystickaxis,
   love.joystickhat,
   love.joystickpressed,
   love.joystickreleased,
   --MISC--
   love.threaderror,
   love.textedited,
   love.textinput,
   --love.errhand, --Not sure I want to override these
   --love.errorhandler, --Not sure I want to override these
}

------------------------------------------
--love.run	The main function, containing the main loop. Here for completeness,
--in case it needs to be modified.
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
------------------------------------------
write(out, 'local args = {...} --Get arguments passed when this module is loaded\n')
write(out, 'local q = args[1] --The main Queue object from main.lua\n')
write(out, 'local love = args[2] --The main Löve table from main.lua\n\n')

for k,v in ipairs(function_names) do
   make_generic_callback(v)
end
------------------------------------------
