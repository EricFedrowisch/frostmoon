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
local key_constants = require "lib.key_constants"
local Hotkey = {}
local modifier_keys = {
rshift="rshift", --	Right shift key
lshift="lshift", --	Left shift key
rctrl="rctrl", --	Right control key
lctrl="lctrl", --	Left control key
ralt="ralt", --	Right alt key
lalt="lalt", --	Left alt key
rgui="rgui", --	Right gui key (Win or CMD on Mac)
lgui="lgui", --	Left gui key (Win or CMD on Mac)
mode="mode", --	Mode key
}

Hotkey.defaults = {
   key_constants = key_constants, --All key constants for lookup
   bound_keys = {}, --Keys of interest that are bound in hotkey combos. Others are basically ignored.
   key_fx = {}, --Functions to fire when a given key comboniation is released or released
   modifier_keys = modifier_keys,
}

function Hotkey:validate_keybind(keys, fx)
   local valid = true
   if type(keys) ~= "table" then valid = false; return valid end --Should be list of keys in a table
   for i,v in pairs(keys) do
      if type(v) ~= "string" then valid = false; return valid  end
      if not key_constants[v] then valid = false; print("Key: " .. v .. " not in key constants"); return valid end --
   end
   if type(fx) ~= "function" then valid = false; return valid end
   return valid
end

--Register a function to call when key is pressed.
--Arguments are:
--keys = keys to press
--fx = function to call when key is released
--on_press = false by default, true if key combo should call function while held down

function Hotkey:register_key(keys, fx, on_press)
   if not self:validate_keybind(keys, fx) then error("Invalid keybind") end
   for _,v in ipairs(keys) do self.bound_keys[v] = true end --Add keys to bound keys
   table.sort(keys) --Sort keys
   local kstr = table.concat(keys, ",")
   local on_press = on_press or false
   if on_press then kind = "press-" else kind = "release-" end
   self.key_fx[kind .. kstr] = fx --Register keybind lookup string made of type and keys
end

function Hotkey:get_modifier_keys_down()
   local keys = {}
   for k,v in pairs(self.modifier_keys) do
      if love.keyboard.isDown(v) then keys[#keys+1]=v end
   end
   return keys
end

function Hotkey:key_event(msg, kind)
   if self.bound_keys[msg.args.key] then --Key is one that is bound
      local keys = {msg.args.key} --Get key
      local mods = self:get_modifier_keys_down()
      for i = 1, #mods do keys[#keys+1]=mods[i] end
      table.sort(keys)
      local lookup = kind .. table.concat(keys, ",")
      if self.key_fx[lookup] ~= nil then
         self.key_fx[lookup]()
         msg.handled = 1
      end
   end
end

Hotkey.event_types = {
   keypressed  = function(self, msg) self:key_event(msg, "press-") end,
   keyreleased = function(self, msg) self:key_event(msg, "release-") end,
}

return Hotkey
