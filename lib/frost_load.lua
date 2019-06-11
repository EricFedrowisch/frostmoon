--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
This script parses the component directory recursively making all the files into
frostmoon component object classes.
--]]
------------------------------------------

--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      components = exports.components,
      component_dir = component_dir,
          }
end

local component_dir = "components" --Directory from which to recursively load components
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

local function _load_components(dir, recurse, _components)
   local components = _components or {}
   local files, dirs = {}, {}
   for i,fh in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local handle = dir .. os_sep .. fh
      local info = love.filesystem.getInfo(handle)
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
      if components[path] == nil or type(components[path]) ~= "table" then
         print("ERROR: Component file not returning table at ", file)
         components[path] = nil --Delete malformed component
      else
         --Set component private variables here
         components[path]._type = path
         components[path]._load_path = file
      end
   end
   if recurse then
      for i, dir in ipairs(dirs) do
         components = _load_components(dir, recurse, components)
      end
   end
   return components
end

------------------------------------------
local target_dir = "" .. os_sep  .. component_dir
exports.components = _load_components(target_dir, true)
------------------------------------------

return export()
