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

function Button:handle_event(msg)
   local response = nil
   if msg.type == "push" then self:push() end
   if msg.type == "echo" then response="ECHO" end
   return response
end

Button.event_types = {
   ["push"]=1,
   ["echo"]=1,
}


return Button
