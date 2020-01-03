--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
Resources library. This script parses the "res" folder and loads various types
of resources from files into forms usable by löve. It loads images from
"res/img", sounds from "res/snd", longer music files from "res/msx" and font
files from "res/fnt".
It also has utility functions for resource related needs such as resizing
images.
--]]
------------------------------------------

--Directory path variables
local res_dir = "" .. _G.OS.sep  .. "res"
local img_dir = res_dir .. _G.OS.sep  .. "img"
local snd_dir = res_dir .. _G.OS.sep  .. "snd"
local msx_dir = res_dir .. _G.OS.sep  .. "msx"
local fnt_dir = res_dir .. _G.OS.sep  .. "fnt"
--Tables of supported image types
local img_types_supported = {["png"] = true, ["tga"] = true}
local fnt_types_supported = {["ttf"] = true}
local snd_types_supported = {["wav"] = true, ["mp3"] = true, ["ogg"] = true, ["oga"] = true, ["ogv"] = true}

--Recursively get all files in dir and subdirs. Return table with filepaths.
local function get_files(dir, _files)
   local filelist = _files or {} --Either make a new empty list or use recursive call results
   local files, dirs = {}, {}
   for i,fh in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local handle = dir .. _G.OS.sep .. fh
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
         img_name = v:gsub(img_dir .. _G.OS.sep, "")
         imgs[img_name] = love.graphics.newImage(v)
      end
   end
   return imgs
end

--Resize all current images
local function resize_imgs(imgs)
   for k, e in pairs(imgs) do --For each img...
      e.image = res.resize(e.image_initial, e.psp_x, e.psp_y, e.maintain_aspect_ratio)
   end
   love.graphics.setCanvas() --Important! Reset draw target to main screen.
end

--Resize an image file.
local function resize(img, psp_x, psp_y, maintain_aspect_ratio)
   local psp_width  = (love.graphics.getWidth() * psp_x)
   local psp_height =  (love.graphics.getHeight() * psp_y)
   local sx = psp_width/img:getWidth() --Calculate image width scale
   local sy = psp_height/img:getHeight() --Calculate image height scale
   local fx, fy = 1, 1
   if maintain_aspect_ratio then
      fx, fy = math.min(sx, sy), math.min(sx, sy)
   else
      fx, fy = sx, sy
   end
   local cnvs = love.graphics.newCanvas(img:getWidth()*fx, img:getHeight()*sy) --Create temp canvas
   love.graphics.setCanvas(cnvs) --Make temp canvas current draw target
   love.graphics.draw(img, 0, 0, 0, fx, fy) --Draw image resized
   love.graphics.setCanvas() --Important! Reset draw target to main screen.
   img = love.graphics.newImage(cnvs:newImageData()) --Make new image from canvas ImageData
   cnvs = nil --Delete temp canvas reference so it can be garbage collected
   return img
end

--Return table of sounds loaded into memory
local function load_sounds()
   local snds = {}
   local snd_files = get_files(snd_dir)
   for i,v in ipairs(snd_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if snd_types_supported[f_type] ~= nil then --If file type supported
         -- the "static" tells LÖVE to load the file into memory, good for short sound effects
         snds[v:gsub(snd_dir .. _G.OS.sep, "")] = love.audio.newSource(v, "static")
      end
   end
   return snds
end

--Return table of functions that will stream a music file if called, then invoked with music:play()
local function load_music()
   local msx = {}
   local msx_files = get_files(msx_dir)
   for i,v in ipairs(msx_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if snd_types_supported[f_type] ~= nil then --If file type supported
         -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
         msx[v:gsub(msx_dir .. _G.OS.sep, "")] = function () return love.audio.newSource(v, "stream") end --Returning function here to keep memory cost low.
      end
   end
   return msx
end

--Return table of ttf style fonts (non-glyph) objects initialized to font size 12.
--The font files  are loaded seperately for making fonts of different sizes.
local function load_fonts()
   local fnts, files = {}, {}
   local fnt_files = get_files(fnt_dir)
   for i,v in ipairs(fnt_files) do
      local f_type =  v:match("[^.]+$") --Get file extension
      if fnt_types_supported[f_type] ~= nil then --If file type supported
         local key = v:match("[^/]+$")
         files[key] = v
         fnts[key] = love.graphics.newFont(v, 12)
      end
   end
   fnts.default = love.graphics.newFont(12)
   return fnts, files
end

--Returns the width to height ratio of a given element or the ratio for the
--screen if called without an element
local function width_height_ratio(element)
   local e = {}
   if element ~= nil then
      if element.height ~= nil and element.width ~= nil then
         e.height, e.width = element.height, element.width
      end
   end
   if e.height == nil and e.width == nil then
      e.height, e.width = love.graphics.getWidth(), love.graphics.getHeight()
   end
   return e.width/e.height
end

local function load_resources(dir)
   _G.res = {}
   res.img = load_imgs()
   res.snd = load_sounds()
   res.msx = load_music()
   res.fnt, res.fnt_files = load_fonts()
   res.size = {} --Store original screen size
   res.size.width  = love.graphics.getWidth()
   res.size.height = love.graphics.getHeight()
   --Store image resize functions
   res.resize_imgs = resize_imgs
   res.resize = resize
   res.width_height_ratio = width_height_ratio
   res.get_files = get_files
end
------------------------------------------

return load_resources(res_dir)
