--[[Simple test object here for testing package loader]]
local Object = {}

Object.defaults = {
   ["def1"] = 1,
   ["def2"] = "If you see this defaults are working"
}

Object.event_types = {
   ["test"]=function(self,msg) return "TEST" end,
   ["echo"]=function(self,msg) return "ECHO" end,
}

return Object
