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

local function make_class_syntax_binding(ckey, cval)
   local class = cval.classname
   if _G[class] ~= nil then
      error("Class namespace collision (two or more global variables/classes with same name): " .. cval.classname)
   else
      _G[class] = function (...)
         local args = {}
         local container = nil
         args.component_type = cval.component_type
         for i,n in pairs({...}) do
            for k,v in pairs(n) do
               if k ~= '__container' then
                  args[k] = v
               else
                  container = v
               end
            end
         end
         return exports.Component.new(args, container)
      end
   end
end

for ck, cv in pairs(exports.components) do --For each component type...
   exports.instances[ck] = {} --Create tables to store component instance uuids by component type
   make_class_syntax_binding(ck, cv)
   local parent = cv.__parent or exports.Component --Allow for single line inheritance
   setmetatable(cv, {__index = parent})
end

--Right now frostmoon has to be in Global namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
return _G.frostmoon
