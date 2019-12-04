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
      if _G.debug_modes.more_info then print("Component Loading: " .. handle) end
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
