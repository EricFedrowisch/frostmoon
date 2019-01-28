--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------

--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      components = exports.components,    --Table of component types
      instances  = exports.instances,     --Table of component instances
      Component  = exports.Component,     --Base Component prototype
      new        = exports.Component.new, --Convenience binding of Component.new()
      queue      = exports.queue,         --Frost Queue Class
          }
end


------------------------------------------
local frost_proto = require("frost_proto")
exports.Component = frost_proto.component_prototype

local frost_load = require("frost_load")
exports.components = frost_load.components

exports.queue = require "frost_queue"

exports.instances = {["_uuid"] = {}} --Create Component instances table

for k,v in pairs(exports.components) do --For each component type...
   exports.instances[k] = {} --Create tables to store component instance uuids by component type
   setmetatable(v, {__index = exports.Component})--Makes dynamically loaded components inherit from Component
end

--This is here for a reason, even tho I don't like putting things in gloabl namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
return _G.frostmoon
