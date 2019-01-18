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
         write(out, def)
         write(out, "msg = {\n    ")
         write(out, "[\"type\"] = " .. '"' .. f_args[1] .. '"' .. ",\n    ")
         write(out, "[\"args\"] = {\n        ")
         for k,v in pairs(f_args) do
            if k > 1 then
               write(out, "[\""..v.."\"] = ".. v)
               if k ~= #f_args then write(out, ",\n        ") end
            end
         end
         write(out, "\n    }\n")
         write(out, "}\n")
         write(out, "q:add(msg)\n")
         write(out, "end\n\n")
      end
   end

end

------------------------------------------
--Shell Function declarations.
--Callback function triggered when the mouse is moved.
function love.mousemoved(x, y, dx, dy, istouch) end
--Callback function triggered when a key is pressed.
function love.keypressed(key, scancode, isrepeat) end
--Callback function triggered when a keyboard key is released.
function love.keyreleased(key, scancode) end
------------------------------------------
------------------------------------------
local function_names = {
   love.mousemoved,
   love.keypressed,
   love.keyreleased,
}
------------------------------------------
write(out, 'local args = {...} --Get arguments passed when this module is loaded\n')
write(out, 'local q = args[1] --The main Queue object from main.lua\n')
write(out, 'local love = args[2] --The main Löve table from main.lua\n\n')

for k,v in ipairs(function_names) do
   make_generic_callback(v)
end

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
