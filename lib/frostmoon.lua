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
local component_dir = _G.OS.component_dir --Directory from which to recursively load components
local exports = {} --Temp storage for exported functionality
exports.Component = require "lib.component"
--"Table of Contents" for exports of the module

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

--[[
Takes:
   - str = string to split
   - sep = seperator to use to split string (default is whitespace)
Returns:
   - an indexed table of strings
--]]
local function split(str, sep)
   local t={}
   if sep == nil then sep = "%s" end --Default to whitespace
   for str in string.gmatch(str, "([^"..sep.."]+)") do
      t[#t+1] = str
   end
   return t
end

local function make_class_key(path)
   local f = split(path, _G.OS.sep)
   local split_index = nil
   local name = split(f[#f],".");name = name[1];f[#f]=name --Get file name minus '.lua'
   for i,v in ipairs(f) do  --Find component dir index
      if f[i] == component_dir then split_index = i; break end
   end
   for i,v in ipairs(f) do --Delete preceding path before
      if i < split_index then f[i] = nil end
   end
   local t = {}
   for i = split_index + 1,#f do t[#t+1] = f[i] end
   return table.concat(t,'.'), t[#t]
end

local function make_class_def(key, classname, class_table)
   local component = class_table
   if class_table == nil or type(class_table) ~= "table" then
      component = {}
   end
   component.component_type = key
   component.classname = classname
   component._load_path = path
   return component
end

local function make_classes(paths)
   local components = {}
   for _, path in ipairs(paths) do
      local key, classname = make_class_key(path)
      local class_table = love.filesystem.load(path)()
      if class_table == nil or type(class_table) ~= "table" then
         error("ERROR: Component file not returning table at " .. path)
      else
         components[key] = make_class_def(key, classname, class_table)
      end
   end
   components["Component"] = make_class_def("Component", "Component", exports.Component)
   return components
end

--[[
local function add_class_def(key, class_table)
   if _G[class] ~= nil then
      error("Class namespace collision (two or more global variables/classes with same name): " .. key)
   else
   _G.frostmoon.components[key] = make_class_def(key, key, class_table)
   end
end
]]

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

local function load_components(dir)
   local files = _G.frost_sys.get_file_paths(dir)
   return make_classes(files)
end

exports.queue = require "lib.queue"
exports.instances = {["_uuid"] = {}} --Create Component instances table
exports.components = load_components(component_dir)


for ck, cv in pairs(exports.components) do --For each component type...
   exports.instances[ck] = {} --Create tables to store component instance uuids by component type
   make_class_syntax_binding(ck, cv)
   if ck ~= "Component" then
      local parent = exports.components[cv.__parent] or exports.Component --Allow for single line inheritance
      setmetatable(cv, {__index = parent})
   end
end

--Right now frostmoon has to be in Global namespace.
_G.frostmoon = export()--Basically needed to avoid null pointers in the Component code.
--return _G.frostmoon
