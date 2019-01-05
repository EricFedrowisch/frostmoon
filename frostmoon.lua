--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]

--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      components = exports.components,    --Table of component types
      instances  = exports.instances,     --Table of component instances
      Component  = exports.Component,     --Base Component prototype
      Message    = exports.Message,       --Base Inter-Component Message prototype
      new        = exports.Component.new  --Convenience binding of Component.new()
          }
end


------------------------------------------
local Component = {}
local frost_load = require("frost_load")
local instances = {["_uuid"] = {}}

exports.instances = instances
exports.components = frost_load.components

local frost_proto = require("frost_proto")
exports.Component = frost_proto.component_prototype
local Message = frost_proto.Message
exports.Message = Message

for k,v in pairs(exports.components) do --For each component type...
   exports.instances[k] = {} --Create tables to store component instance uuids by component type
   setmetatable(v, {__index = exports.Component})
end
_G.frostmoon = export()
return export()
