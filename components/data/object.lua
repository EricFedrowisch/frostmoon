--[[Simple test object here for testing package loader]]
local function new(args)
   local obj = {}
   obj.is_component = true
   obj.component_type = "data.object"
   obj.var1 = "Object.lua code here"
   obj.var2 = 3
   obj.var3 = 2
   return obj
end

local t = {}
t.new = new

return t
