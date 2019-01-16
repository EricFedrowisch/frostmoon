--[[Frame object class. Controls the main display of the app.]]
local Frame = {}

Frame.defaults = {
   ["x"] = 0,
   ["y"] = 0,
   ["height"] = 100,
   ["width"] = 200,
   ["fullscreen"]=false,
}



Frame.event_types = {
   ["init"]=function(self, msg) print("Init Frame") end,
}

return Frame
