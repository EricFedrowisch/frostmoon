--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
This component contains the keyboard support code. This gives support for catching
keyboard events and invoking functions in response to those events.
--]]
------------------------------------------
local keys = require "key_constants"
local Hotkey = {}


Hotkey.defaults = {
   ["keys"] = keys,
   ["key_fx"] = {},
}

--Register a function to call when key is pressed.
function Hotkey:register_key(k, fx)
   if k ~= nil and fx ~=nil then --and type(k) == "string" and type(fx) == "function" then
      self.key_fx[k] = fx
   end
end

function Hotkey:release(msg)
   --print("Release", msg.dt)
   if _G.draw_debug then
      _G.d.line()
      _G.d.tprint(msg)
      _G.d.line()
   end
   if self.key_fx[msg.args.key] ~= nil and msg.handled ~= 1 then
      self.key_fx[msg.args.key]()
      msg.handled = 1
   end
end

function Hotkey:pressed(msg)
   --print("Press", msg.dt)
   if _G.draw_debug then
      d.line()
      d.tprint(msg)
      d.line()
   end
end


Hotkey.event_types = {
   ["keypressed"]  =function(self, msg) self:pressed(msg) end,
   ["keyreleased"] =function(self, msg) self:release(msg) end,
}

return Hotkey
