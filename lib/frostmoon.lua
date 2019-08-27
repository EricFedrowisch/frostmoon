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
local component = require("component")
exports.Component = component.component_prototype

local load = require("load")
exports.components = load.components

exports.queue = require "queue"

exports.instances = {["_uuid"] = {}} --Create Component instances table

local function make_class_type(ckey, cval)
   --Error testing...
   if _G[cval.classname] ~= nil then
      error("Class namespace collision (two or more global variables/classes with same name): " .. cval.classname)
   else
      _G[cval.classname] = cval
   end

   exports.instances[ckey] = {} --Create tables to store component instance uuids by component type

   local fcall = function (args)
      args.component_type = cval.component_type
      return component.component_prototype:new(args)
   end

   local meta = {}
   meta.__index = cval.__parent or exports.Component
   meta.__call = fcall
   setmetatable(cval, meta)
end

for ck,cv in pairs(exports.components) do --For each component type...
   make_class_type(ck, cv)
end

--Right now frostmoon has to be in Global namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
return _G.frostmoon
