--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   ["x"] = 0,
   ["y"] = 0,
   ["toggleable"]=false,
}

Button.event_types = {
   ["push"]=function(self, msg) print("Button uuid" .. tostring(self._uuid) .. " pushed.") end,
   ["echo"]=function(self, msg) return "ECHO" end,
}

return Button
