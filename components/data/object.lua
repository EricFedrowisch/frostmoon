--[[Simple test object here for testing package loader]]

local _defaults = {["def1"] = 1, ["def2"] = "default #2"}

local function new(args, container)

--Generic object instantiation
-----------------------------------
   local obj = {}
   obj = _G.frostmoon.new(args, obj)
-----------------------------------
   return obj
end

local t = {}
t.new = new
t._defaults = _defaults

return t
