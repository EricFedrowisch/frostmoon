--[[Simple test object here for testing package loader]]
local function new(args)
--Generic object instantiation
-----------------------------------
   local obj = {}
   obj = _G.frostmoon.new(args, obj)
-----------------------------------
   return obj
end

local t ={}
t.new = new

return t
