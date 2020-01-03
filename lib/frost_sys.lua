--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
This lib file has functions for parsing the component directory recursively
so that the files can be loaded as frostmoon component classes.
--]]
------------------------------------------

--Operating system info for file system
_G.OS = {}
_G.OS.os_name = love.system.getOS() --The current operating system. "OS X", "Windows", "Linux", "Android" or "iOS".
if _G.OS.os_name ~= "Windows" then
   _G.OS.sep = package.config:sub(1,1) --File system seperator (\ or / usually)
else
   _G.OS.sep = '/'
end
_G.OS.is_fused = love.filesystem.isFused()
_G.OS.cwd = love.filesystem.getWorkingDirectory
_G.OS.source_path = love.filesystem.getSourceBaseDirectory()


--Lookup table for library file paths
local lib_locs = {
   ["OS X"]    = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep,
   ["iOS"]     = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
   ["Windows"] = '/'  .. "lib" .. '/',
   ["Linux"]   = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
   ["Android"] = "" .. _G.OS.sep  .. "lib" .. _G.OS.sep, --UNTESTED
}
_G.OS.lib = lib_locs[_G.OS.os_name] --Set library file path according to OS
--Lookup table for component classes' file paths
local comp_locs = {
   ["OS X"]    = "components",
   ["iOS"]     = "components", --UNTESTED
   ["Windows"] = "components",
   ["Linux"]   = "components", --UNTESTED
   ["Android"] = "components", --UNTESTED
}

_G.OS.component_dir = comp_locs[_G.OS.os_name] --Set component classes' file path according to OS
local reqstr = string.gsub(love.filesystem.getRequirePath() .. ";" .. _G.OS.lib .. "?.lua", '/', '\\')
love.filesystem.setRequirePath(reqstr)
local creqstr =  string.gsub(love.filesystem.getCRequirePath() .. ";" .. _G.OS.lib .. "??", '/', '\\')
love.filesystem.setCRequirePath(creqstr)
_G.OS.require_path = love.filesystem.getRequirePath()
_G.OS.c_require_path = love.filesystem.getCRequirePath()

------------------------------------------
--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      get_file_paths = exports.get_file_paths,
          }
end

------------------------------------------

--Return a list of files' paths from directory and its subdirectories
local function get_file_paths(dir, files)
   local files = files or {}
   local dirs = {}
   for i,fh in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local handle = dir .. _G.OS.sep .. fh
      local info = love.filesystem.getInfo(handle)
      if _G.f_debug ~= nil then if _G.f_debug.more_info then print("Component Loading: " .. handle) end end
      if info.type == "file" then files[#files + 1] = handle end
      if info.type == "directory" then dirs[#dirs+1] = handle end
   end
   for i, dir in ipairs(dirs) do
      files = get_file_paths(dir, files)
   end
   return files
end
exports.get_file_paths = get_file_paths

------------------------------------------
return export()
