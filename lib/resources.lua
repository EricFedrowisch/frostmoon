--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--Directory path variables
local res_dir = "" .. os_sep  .. "res"
local img_dir = res_dir .. os_sep  .. "img"
local snd_dir = res_dir .. os_sep  .. "snd"
--Table of supported image types
local img_types_supported = {["png"] = true, ["tga"] = true}

local function _split(str, sep)
   local t={}
   if sep == nil then sep = "%s" end --Default to whitespace
   for str in string.gmatch(str, "([^"..sep.."]+)") do
      t[#t+1] = str
   end
   return t
end

--Recursively get all files in dir and subdirs. Return table with filepaths.
local function get_files(dir, _files)
   local filelist = _files or {}
   local files, dirs = {}, {}
   for i,fh in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local handle = dir .. os_sep .. fh
      local info = love.filesystem.getInfo(handle)
      if info.type == "file" then files[#files + 1] = handle end
      if info.type == "directory" then dirs[#dirs+1] = handle end
   end
   for i,file in ipairs(files) do
      filelist[#filelist + 1] = file
   end
   for i, dir in ipairs(dirs) do
      filelist = get_files(dir, filelist)
   end
   return filelist
end

--Returns table of löve image objects with keys that are their subdirectory path
--ie res.img["button/button.png"] = Image: 0x7f9c89c77590
local function load_imgs()
   local imgs = {}
   local img_files = get_files(img_dir)
   for i,v in ipairs(img_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if img_types_supported[f_type] ~= nil then --If file type supported
         imgs[v:gsub(img_dir .. os_sep, "")] = love.graphics.newImage(v)
      end
   end
   --d.tprint(imgs)
   return imgs
end

local function load_sounds()
   local snds = {}
   return snds
end


local function load_resources(dir)
   local res = {} --Initiale resources table
   res.img = load_imgs()
   res.snd = load_sounds()
   return res
end
------------------------------------------

return load_resources(res_dir)
