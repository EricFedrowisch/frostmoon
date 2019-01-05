--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["x"] = 0,
   ["y"] = 0,
   ["toggleable"]=false,
}

function Button:push()
   print("Button uuid" .. tostring(self._uuid) .. " pushed.")
end

return Button
