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

local d = require("frost_debug")
local component_dir = "components" --Directory from which to recursively load components
local lfs = love.filesystem
------------------------------------------
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local lib_string = ";" .. lfs.getWorkingDirectory() .. os_sep .. "lib" .. os_sep .. "?.lua"
local socket_lib = ";" .. lfs.getWorkingDirectory() .. os_sep .. "lib" .. os_sep .. "socket" .. os_sep .. "?.lua"
local socket_lib_cpath = ";" .. lfs.getWorkingDirectory() .. os_sep .. "lib" .. os_sep .. "?.so"
--package.path = package.path .. lib_string .. socket_lib

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

local function _load_components(dir, recurse, _components)
   local components = _components or {}
   local files, dirs = {}, {}
   package.path = package.path .. ";" .. dir .. os_sep .. "?.lua" --Add to path for require
   for i,v in ipairs(lfs.getDirectoryItems(dir)) do
      if (v ~= ".") and (v ~= "..") then --#TODO:Check does this work on Windows, iOS & Linux?
         local f = dir .. os_sep .. v
         if lfs.isFile(f) then
            local parse = {f:match("(.-)([^\\/]-([^\\/%.]+))$")} --String MAAAAAAGIC!
            if (parse[3]:lower() == 'lua') and (parse[2] ~= arg[0]) then --If lua and not this script itself
               files[#files+1]=f
            end
         end
         if lfs.isDirectory(f) then dirs[#dirs+1]=f end
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
--]]
local function _load_components(dir, recurse, _components)
   local components = _components or {}
   local files, dirs = {}, {}
   for i,fh in ipairs(lfs.getDirectoryItems(dir)) do
      local handle = dir .. os_sep .. fh
      local info = lfs.getInfo(handle)
      if info.type == "file" then files[#files + 1] = handle end
      if info.type == "directory" then dirs[#dirs+1] = handle end
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
      components[path]=love.filesystem.load(file)()
      --Set component private variables here
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
--orig_packagepath = package.path --Store package.path before
--local target_dir = lfs.getWorkingDirectory() .. os_sep .. component_dir .. os_sep

local target_dir = "" .. os_sep  .. component_dir --.. os_sep
--local require_path = love.filesystem.getRequirePath() .. ";" .. target_dir
--love.filesystem.setRequirePath(require_path)
exports.components = _load_components(target_dir, true)
--package.path = orig_packagepath --Restore package.path
------------------------------------------

return export()
