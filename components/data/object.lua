--[[Simple test object here for testing package loader]]
local function new(args, container)
   local defaults = {["def1"] = 1, ["def2"] = "default #2"}
-----------------------------------
   local obj = {}
   for k,v in pairs(args) do
      if type(v) ~= "table" then
         obj[k] = v
      else
         obj[k] = _G.frostmoon.new(v, obj)
      end
   end
   for k,v in pairs(defaults) do
      if obj[k] == nil then obj[k] = v end
   end
-----------------------------------
   return obj
end

local t = {}
t.new = new

return t
