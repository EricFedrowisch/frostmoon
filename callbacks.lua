--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local d = require "frost_debug"
local args = {...} --Get arguments passed when this module is loaded
local q = args[1] --The main Queue object from main.lua
local love = args[2] --The main Löve table from main.lua
local lines = {} --Table to hold lines of source code
local file_path = "./callbacks.lua" --Path to source file
for line in io.lines(file_path) do table.insert(lines, line) end --Get source
--d.tprint(lines)
------------------------------------------

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
   print("Making generic callback for:", tostring(lines[debug.getinfo(f, 'nSL').linedefined]))
   local info = debug.getinfo(f, 'nSL')
   local f_args = {}
   if info ~= nil then
      if info.linedefined == info.lastlinedefined then --Should be a shell
         f_args = parse_def(lines[info.linedefined]) --Parse source line for arg names
      end
   end
   f = function(...)
      --print("Invoked:", tostring(lines[debug.getinfo(f, 'nSL').linedefined]))
      local msg = {["type"] = f_args[1], ["args"] = arg}
      q:add(msg)
   end
   return f
end


------------------------------------------
--Shell Function declarations.
--Callback function triggered when the mouse is moved.
function love.mousemoved(x, y, dx, dy, istouch) end
love.mousemoved = make_generic_callback(love.mousemoved)
--Callback function triggered when a key is pressed.
function love.keypressed(key, scancode, isrepeat) end
--Callback function triggered when a keyboard key is released.
function love.keyreleased(key, scancode) end
------------------------------------------






--[[

Desktop Specific
love.filedropped	Callback function triggered when a file is dragged and dropped onto the window.
love.directorydropped	Callback function triggered when a directory is dragged and dropped onto the window.

Mobile Specific
love.displayrotated	Called when the device display orientation changed.
love.touchmoved	Callback function triggered when a touch press moves inside the touch screen.
love.touchpressed	Callback function triggered when the touch screen is touched.
love.touchreleased	Callback function triggered when the touch screen stops being touched.

General
love.errhand	The error handler, used to display error messages.
love.errorhandler	The error handler, used to display error messages.
love.threaderror	Callback function triggered when a Thread encounters an error.

Low Priority Atm
love.gamepadaxis	Called when a Joystick's virtual gamepad axis is moved.
love.gamepadpressed	Called when a Joystick's virtual gamepad button is pressed.
love.gamepadreleased	Called when a Joystick's virtual gamepad button is released.
love.joystickadded	Called when a Joystick is connected.
love.joystickaxis	Called when a joystick axis moves.
love.joystickhat	Called when a joystick hat direction changes.
love.joystickpressed	Called when a joystick button is pressed.
love.joystickreleased	Called when a joystick button is released.
love.joystickremoved	Called when a Joystick is disconnected.
]]
--bind_callbacks()

--[[
function love.mousemoved(x, y, dx, dy, istouch)
   q:add({
      ["type"]="mouse_move",
      ["args"] = {
         ["x"] = x,
         ["y"] = y,
         ["dx"] = dx,
         ["dx"] = dy,
         ["istouch"] = istouch}
   })
end
]]
