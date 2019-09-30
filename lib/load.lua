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

local function make_class_key(path)
   local f = _split(path, _G.OS.sep)
   local _split_index = nil
   local name = _split(f[#f],".");name = name[1];f[#f]=name --Get file name minus '.lua'
   for i,v in ipairs(f) do  --Find component dir index
      if f[i] == component_dir then _split_index = i; break end
   end
   for i,v in ipairs(f) do --Delete preceding path before
      if i < _split_index then f[i] = nil end
   end
   local t = {}
   for i = _split_index + 1,#f do t[#t+1] = f[i] end
   return table.concat(t,'.'), t[#t]
end

local function make_classes(paths)
   local components = {}
   for _, path in ipairs(paths) do
      local key, classname = make_class_key(path)
      components[key]=love.filesystem.load(path)()
      if components[key] == nil or type(components[key]) ~= "table" then
         print("ERROR: Component file not returning table at ", file)
         components[key] = nil --Delete malformed component
      else
         --Set component private variables here
         components[key].component_type = key
         components[key].classname = classname
         components[key]._load_path = path
      end
   end
   return components
end

--Return a list of files' paths from directory and its subdirectories
local function get_file_paths(dir, files)
   local files = files or {}
   local dirs = {}
   for i,fh in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local handle = dir .. _G.OS.sep .. fh
      local info = love.filesystem.getInfo(handle)
      if _G.debug_modes.more_info then print("Component Loading: " .. handle) end
      if info.type == "file" then files[#files + 1] = handle end
      if info.type == "directory" then dirs[#dirs+1] = handle end
   end
   for i, dir in ipairs(dirs) do
      files = get_file_paths(dir, files)
   end
   return files
end

local function load_components(dir)
   local files = get_file_paths(dir)
   return make_classes(files)
end

------------------------------------------
exports.components = load_components(component_dir)
------------------------------------------
return export()
