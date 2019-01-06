--[[Simple test object here for testing package loader]]
local Object = {}

Object.defaults = {
   ["def1"] = 1,
   ["def2"] = "If you see this defaults are working"
}

function Object:test()
   print("TEST")
end


function Object:handle_event(msg)
   local response = nil
   if msg.type == "test" then response="TESTED" end
   if msg.type == "echo" then response="ECHO" end
   return response
end

Object.event_types = {
   ["test"]=1,
   ["echo"]=1,
}

return Object
