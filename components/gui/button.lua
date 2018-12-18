--[[Simple Button class here.]]
local Button = {}
Button._defaults = {["x"] = 0, ["y"] = 0}

function Button:new(args)

--Generic Button instantiation
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

return Button
