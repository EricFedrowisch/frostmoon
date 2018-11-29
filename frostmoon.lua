--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.

#TODO:Add warnings for: component already exists, global namespace polluted by loaded
      component (possibly penlight Strict could provide when frostmoon in debug mode)
#TODO: Add CPath searcher & loading capabilities
#TODO: Add component referencing so you can message all of one component type and find their count
#TODO: Write destroy object code
--]]
------------------------------------------
local d = require("frost_debug")
print("Frostmoon Begin Loading", "Mem Usage in Bytes:" .. d.mem_use())
local component_dir = "components" --Directory from which to recursively load components
local lfs = require("lfs")
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

if debug_on then local tablex = require("tablex") end

local exports = {} --Temp storage for exported functionality

--"Table of Contents" for exports of the module
local function export()
   return {
      new = exports.new,
      components = exports.components,
      instances = exports.instances
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
local function _direct_message(target, msg)
   local response = {}
end

local function _query_state(target, var)
   local response = {}
end

--[[
   Takes:
   -self parameter of object to nullify. Also recursively sets all the
    object's contents to nil. Only meant to be called by self, but could be
    (ab)used with targets other than self.
   Returns:
   -None
--]]
local function _destroy_self(self)
   if type(self) == "table" then
      if self.component_type then
         --print(_G.frostmoon.instances[self.component_type][self._uuid])
         _G.frostmoon.instances[self.component_type][self._uuid]=nil --Will this work...?
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
   obj._uuid = uuid()
   obj._container = container
   if debug_on then obj.args, obj.unused = tablex.deepcopy(args), {}  end --Store original args and track unused args too
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
         if debug_on and
               v.component_type ~= nil and --If arg has component_type..
                  exports.components[v.component_type] == nil then -- BUT its not loaded..
                     obj.unused[k] = tablex.deepcopy(v)             --Track unused arg
         elseif exports.components[v.component_type] then --If existing component
            obj[k] = exports.components[v.component_type].new(v, obj) --then make it
            obj[k]._container = obj
            obj[k]._uuid = uuid()
            obj[k].self = obj[k]
            obj[k]._destroy_self = _destroy_self
            local defaults = exports.components[v.component_type]._defaults
            if defaults then --If there are defaults for the class
               for k,v in pairs(defaults) do --Iterate thru the defaults
                  if obj[k] == nil then obj[k] = v end --Using defaults if no value
               end
            end
            if instances[v.component_type] == nil then instances[v.component_type] = {} end --Create entry for instance type if needed
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
--os.execute('clear')

--[[Exercising the code here]]--
--local debug_on = true
local debug_on = false
local original_cwd = lfs.currentdir()
orig_packagepath = package.path --Store package.path before
local target_dir = lfs.currentdir() .. os_sep .. component_dir .. os_sep
lfs.chdir(target_dir)
exports.components = _load_components(lfs.currentdir(), true)
print("Frostmoon Components Loaded", "Mem Usage in Bytes:" .. d.mem_use())
lfs.chdir(original_cwd)
print("FROSTMOON DEBUG ON:", debug_on)
if debug_on then d.tprint(exports.components) end
package.path = orig_packagepath --Restore package.path
return export()
