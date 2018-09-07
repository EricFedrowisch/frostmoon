--[[Simple test object here for testing package loader]]
local function new(args)
   local obj = {}
   obj.is_component = true
   obj.component_type = "gui.window.square"
   obj.var1 = 1
   obj.var2 = 2
   obj.var3 = 3
   return obj
end

local t ={}
t.new = new

return t
