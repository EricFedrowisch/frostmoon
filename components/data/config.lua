--[[Config data storage.
https://love2d.org/wiki/Config_Files
]]
local lfs = require("lfs")
local Config = {}

Config.defaults = {
   ["file"]="",
   ["path"]="",
   ["values"]= {},
}

function Config.init(msg)
   --
end

Config.event_types = {
   ["init"]=function(self,msg) self:init(msg) end,
   ["get"]=function(self,msg) end,
   ["set"]=function(self,msg) end,
   ["save"]=function(self,msg) end,
   ["load"]=function(self,msg) end,
}

return Config
