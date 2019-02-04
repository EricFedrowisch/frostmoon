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
local msx_dir = res_dir .. os_sep  .. "msx"
--Table of supported image types
local img_types_supported = {["png"] = true, ["tga"] = true}
local snd_types_supported = {["wav"] = true, ["mp3"] = true, ["ogg"] = true, ["oga"] = true, ["ogv"] = true}


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
   local snd_files = get_files(snd_dir)
   for i,v in ipairs(snd_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if snd_types_supported[f_type] ~= nil then --If file type supported
         -- the "static" tells LÖVE to load the file into memory, good for short sound effects
         snds[v:gsub(snd_dir .. os_sep, "")] = love.audio.newSource(v, "static")
      end
   end
   --d.tprint(snds)
   return snds
end

local function load_music()
   local msx = {}
   local msx_files = get_files(msx_dir)
   for i,v in ipairs(msx_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if snd_types_supported[f_type] ~= nil then --If file type supported
         -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
         msx[v:gsub(msx_dir .. os_sep, "")] = function () return love.audio.newSource(v, "stream") end --Returning function here to keep memory cost low.
      end
   end
   --d.tprint(msx)
   return msx
end


local function load_resources(dir)
   local res = {} --Initiale resources table
   res.img = load_imgs()
   res.snd = load_sounds()
   res.msx = load_music()
   return res
end
------------------------------------------

return load_resources(res_dir)
