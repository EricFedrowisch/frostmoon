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
      components = exports.components,
      component_dir = component_dir,
      os_sep = os_sep,
          }
end

local lfs = require("lfs")
local component_dir = "components" --Directory from which to recursively load components

------------------------------------------
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local lib_string = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "?.lua"
local socket_lib = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "socket" .. os_sep .. "?.lua"
local socket_lib_cpath = ";" .. lfs.currentdir() .. os_sep .. "lib" .. os_sep .. "?.so"
package.path = package.path .. lib_string .. socket_lib
package.cpath = package.cpath .. socket_lib_cpath

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

local original_cwd = lfs.currentdir()
orig_packagepath = package.path --Store package.path before
local target_dir = lfs.currentdir() .. os_sep .. component_dir .. os_sep
lfs.chdir(target_dir)
exports.components = _load_components(lfs.currentdir(), true)
lfs.chdir(original_cwd)
package.path = orig_packagepath --Restore package.path

return export()
--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
