--[[Simple test object here for testing package loader]]
local Object = {}
Object._defaults = {["def1"] = 1, ["def2"] = "default #2"}

function Object:new(args)

--Generic object instantiation
-----------------------------------
   for k,v in pairs(self._defaults) do
      if args[k] ~= nil then
         self[k] = args[k]
      else
         self[k] = self._defaults[k]
      end
   end
-----------------------------------
   return self
end

return Object
