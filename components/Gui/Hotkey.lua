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
local keys = require "lib.key_constants"
local Hotkey = {}


Hotkey.defaults = {
   keys = keys,
   key_fx = {},
}

--key_fx = {['k'] = {fx, ...}}

--Register a function to call when key is pressed.
--Arguments are:
--k = key to press (technically called on key release)
--fx = function to call when key is released
--Additional arguments should be strings that correspond to additional keys down too (for things like Ctrl + C ie)
function Hotkey:register_key(k, fx, ...)
   if type(k) == "string" and type(fx) == "function" then --and k ~= nil and fx ~= nil
      if self.key_fx[k] ~= nil then --If there is another keybind already...
         local next = #self.key_fx[k]+1
         self.key_fx[k][next] = {fx, ...} --Add this keybind to the list...
      else
         self.key_fx[k] = {{fx, ...}} --If first keybind to this key, then make table for this key's keybinds
      end
   end
end

function Hotkey:debug(msg)
   if _G.draw_debug then
      d.line()
      d.tprint(msg)
      d.line()
   end
end

function Hotkey:release(msg)
   if self.key_fx[msg.args.key] ~= nil and msg.handled ~= 1 then
      self:activate_key(msg.args.key)
      msg.handled = 1
   end
   self:debug(msg)
end

function Hotkey:activate_key(k)
   local key_info = self.key_fx[k]
   for i,v in ipairs(key_info) do
      if #v > 1 then --Need to check modifier keys
         local all_keys_down = true
         for n=2, #v do --Check if each modifier key is down. If not return false. Default is true.
            if not love.keyboard.isDown(v[n]) then all_keys_down = false end
         end
         if all_keys_down then key_info[i][1]() end
      else
         key_info[i][1]() --Else just call function
      end
   end
end

function Hotkey:pressed(msg)
   self:debug(msg)
end


Hotkey.event_types = {
   keypressed  = function(self, msg) self:pressed(msg) end,
   keyreleased = function(self, msg) self:release(msg) end,
}

return Hotkey
