--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
This script is the main entry point of FrostMoon. It loads the component and
queue classes, preparing them for instantiation. The returned table also has
the "_uuid" table that stores the unique id info for instances.
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
local componet = require("component")
exports.Component = componet.component_prototype

local load = require("load")
exports.components = load.components

exports.queue = require "queue"

exports.instances = {["_uuid"] = {}} --Create Component instances table

for k,v in pairs(exports.components) do --For each component type...
   exports.instances[k] = {} --Create tables to store component instance uuids by component type
   --#TODO: This is naive approach. Breaks multi-level inheritance. Fix by going up chain of parents and make component main parent
   setmetatable(v, {__index = exports.Component})--Makes dynamically loaded components inherit from Component
end

--This is here for a reason, even tho I don't like putting things in gloabl namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
return _G.frostmoon
