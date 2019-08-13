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
   exports.instances[ckey] = {} --Create tables to store component instance uuids by component type
   --#TODO: Naive approach. Breaks multi-level inheritance. Fix by going up chain of parents and make component top parent
   local fcall = function (call_args)
      local args = {}
      for k,v  in pairs(call_args) do args[k] = v end
      args.component_type = cval.component_type
      return component.component_prototype:new(args)
   end
   local meta = {
      __index = exports.Component,
      __call = fcall,
   }
   setmetatable(cval, meta)--Makes dynamically loaded components inherit from Component
   --#TODO:Check here for classname collisions
   _G[cval.classname] = cval
end

for ck,cv in pairs(exports.components) do --For each component type...
   make_class_type(ck, cv)
end

--Right now frostmoon has to be in Global namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
return _G.frostmoon
