--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.

#TODO:Add warnings for:component already exists, global namespace polluted by loaded
      component (possibly penlight Strict could provide when frostmoon in debug mode)
#TODO: Add CPath searcher & loading capabilities
--]]
------------------------------------------
--local debug_on = true
local debug_on = false
local component_dir = "components" --Directory from which to recursively load components
local lfs = require("lfs")
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local lib_string = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "?.lua"
package.path = package.path .. lib_string
------------------------------------------

if debug_on then local tablex = require("tablex") end
local d = require("frost_debug")
local exports = {} --Temp storage for exported functionality

--"Table of Contents" for exports of the module
local function export()
   return {
      new = exports.new,
      components = exports.components,
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

--[[
Takes:
   - args = table of arguements
   - optional container = container for components to pass messages upwards
Returns:
   - a table of components made using args
--]]
local function new(args, container)
   local obj = {}
   obj._container = container
   if debug_on then obj.args, obj.unused = tablex.deepcopy(args), {}  end --Store original args and track unused args too
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
         if debug_on and
               v.component_type ~= nil and --If arg has component_type..
                  exports.components[v.component_type] == nil then -- BUT its nil..
                     obj.unused[k] = tablex.deepcopy(v)             --Track unused arg
         elseif exports.components[v.component_type] then --If existing component
            obj[k] = exports.components[v.component_type].new(v, obj) --then make it
            obj[k]._container = obj
            obj[k].self = obj[k]
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
local original_cwd = lfs.currentdir()
orig_packagepath = package.path --Store package.path before
local target_dir = lfs.currentdir() .. os_sep .. component_dir .. os_sep
lfs.chdir(target_dir)
exports.components = _load_components(lfs.currentdir(), true)
lfs.chdir(original_cwd)
print("FROSTMOON DEBUG ON:", debug_on)
if debug_on then d.tprint(exports.components) end
package.path = orig_packagepath --Restore package.path
return export()
