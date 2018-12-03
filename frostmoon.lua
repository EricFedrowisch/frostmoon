--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.

#TODO:Add warnings for: component already exists, global namespace polluted by loaded
      component (possibly penlight Strict could provide when frostmoon in debug mode)
#TODO: Add CPath searcher & loading capabilities
--]]

--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      new = exports.new,
      components = exports.components,
      instances = exports.instances
          }
end

local debug_on = false
------------------------------------------
local d = require("frost_debug")
local lfs = require("lfs")

------------------------------------------
local component_dir = "components" --Directory from which to recursively load components
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local lib_string = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "?.lua"
local socket_lib = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "socket" .. os_sep .. "?.lua"
local socket_lib_cpath = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "?.so"
package.path = package.path .. lib_string .. socket_lib
package.cpath = package.cpath .. socket_lib_cpath
------------------------------------------
--UUID Requires here
local socket = require("socket")
local uuid = require("uuid")
uuid.randomseed(socket.gettime()*10000)
------------------------------------------

if debug_on then
   local tablex = require("tablex")
   print("Frostmoon Begin Loading", "Mem Usage in Bytes:" .. d.mem_use())
end


------------------------------------------
--[[
Takes:
   - str = string to split
   - sep = seperator to use to split string (default is whitespace)
Returns:
   - an indexed table of strings
--]]
local function _split(str, sep)
   local t={}
   if sep == nil then sep = "%s" end --Default to whitespace
   for str in string.gmatch(str, "([^"..sep.."]+)") do
      t[#t+1] = str
   end
   return t
end

--[[
Takes:
   - dir = target directory to load components from
   - recurse = boolean for whether to recursively load subdirectories or not
   - _components = internal variable for returning recursive results
Returns:
   - a table of components loaded from target dir
--]]
local function _load_components(dir, recurse, _components)
   local components = _components or {}
   local files, dirs = {}, {}
   package.path = package.path .. ";" .. dir .. os_sep .. "?.lua" --Add to path for require
   for i in lfs.dir(dir) do
      if (i ~= ".") and (i ~= "..") then --#TODO:Check does this work on Windows, iOS & Linux?
         local f = dir .. os_sep .. i
         if lfs.attributes(f,"mode") == "file" then
            local parse = {f:match("(.-)([^\\/]-([^\\/%.]+))$")} --String MAAAAAAGIC!
            if (parse[3]:lower() == 'lua') and (parse[2] ~= arg[0]) then --If lua and not this script itself
               files[#files+1]=f
            end
         end
         if lfs.attributes(f,"mode") == "directory" then dirs[#dirs+1]=f end
      end
   end
   for i,file in ipairs(files) do
      local f = _split(file,os_sep)
      local _split_index = nil
      local name = _split(f[#f],".");name = name[1];f[#f]=name --Get file name minus '.lua'
      for i,v in ipairs(f) do  --Find componet dir index
         if f[i] == component_dir then _split_index = i; break end
      end
      for i,v in ipairs(f) do --Delete preceding path before
         if i < _split_index then f[i] = nil end
      end
      local t = {}
      for i = _split_index + 1,#f do t[#t+1] = f[i] end
      local path = table.concat(t,'.');
      components[path]=require(name)
      --Do component private variables here
      components[path]._type = path
      components[path]._load_path = file
   end
   if recurse then
      for i, dir in ipairs(dirs) do
         components = _load_components(dir, recurse, components)
      end
   end
   return components
end


------------------------------------------
local instances = {}
instances._uuid = {}
exports.instances = instances


--[[
   Message types supported:
      -Direct
      -Top down/Bottom Up (Direct to _container/Direct to contents)
      -Broadcast (Direct to All)
      -All Instances of Type (Direct to all of Type)
      -Lateral (Direct to all of _container's contents)

      #TODO: Consider if coroutines are needed/would be beneficial for
             main execution versus msgs
--]]

--[[

--]]
local function _receive_message(self, msg)
   local response = nil
   if self._component_type then response = self.receive_message(msg) end --Classes should
   return response
end

local function _direct_message(target, msg)
   return target._receive_message(target, msg)
end

local function _message_container(self, msg)
   return _direct_message(self._container, msg)
end

local function _broadcast(msg)
   local responses = {}
   for k,v in pairs(_G.frostmoon.instances._uuid) do
      responses[k]=_direct_message(v, msg)
   end
   return responses
end

local function _broadcast_up(self, msg)
   local response = nil
   local current_container = self._container
   while (response == nil and current_container ~= nil) do
      response = _direct_message(current_container, msg)
      current_container = current_container._container
   end
end

local function _broadcast_down(self, msg)
   local response = nil
   --for each component in contents, call broadcast down
end

local function _broadcast_lateral(self, msg)
   local response = nil
end

local function _query_state(target, var)
   local response = {}
end

--[[
   Takes:
   -self parameter of object to destroy. Also recursively sets all the
    object's contents to nil. Only meant to be called by self, but could be
    (ab)used with targets other than self.
   Returns:
   -None
--]]
local function _destroy_self(self)
   if type(self) == "table" then
      if self.component_type then
         _G.frostmoon.instances[self.component_type][self._uuid]=nil
         _G.frostmoon.instances._uuid[self._uuid]=nil
      end
      for k,v in pairs(self) do
         if k ~= "_container" and k ~= "self" then
            _destroy_self(v)
            v = nil
         end
         if k == "_container" then --Delete container's reference to self
            for k,v in pairs(v) do
               if v == self then v = nil end
            end
         end
      end
   end
   self = nil
end
------------------------------------------
--[[
Takes:
   - args = table of arguements
   - optional container = container for components to pass messages upwards
Returns:
   - a table of components made using args
--]]
local function new(args, container)
   local obj = {}
   if exports.components[args.component_type] then
      obj._container = container
   end
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
         if exports.components[v.component_type] then --If existing component
            obj[k] = exports.components[v.component_type].new(v) --then make it
            obj[k]._container = obj
            obj[k]._uuid = uuid()
            _G.frostmoon.instances._uuid[obj[k]._uuid]=obj[k] --Register UUID
            obj[k].self = obj[k]
            obj[k]._destroy_self = _destroy_self
            local defaults = exports.components[v.component_type]._defaults
            if defaults then --If there are defaults for the class
               for k,v in pairs(defaults) do --Iterate thru the defaults
                  if obj[k] == nil then obj[k] = v end --Using defaults if no value
               end
            end
            instances[v.component_type][obj[k]._uuid] = obj --Keep track of instances for Broadcasts
         elseif  v.component_type == nil then --If table, but not component
            obj[k] = new(v) --then call new
         end
      else --If not table, then not component
         obj[k] = v
      end
   end
  return obj
end
exports.new = new

------------------------------------------

--[[Exercising the code here]]--
local original_cwd = lfs.currentdir()
orig_packagepath = package.path --Store package.path before
local target_dir = lfs.currentdir() .. os_sep .. component_dir .. os_sep
lfs.chdir(target_dir)
exports.components = _load_components(lfs.currentdir(), true)
--Create tables to store component instance uuids by component type
for k,v in pairs(exports.components) do
   exports.instances[k] = {}
end
lfs.chdir(original_cwd)
package.path = orig_packagepath --Restore package.path

if debug_on then
   print("Frostmoon Components Loaded", "Mem Usage in Bytes:" .. d.mem_use())
   print("FROSTMOON DEBUG ON:", debug_on)
   d.tprint(exports.components)
end

return export()
