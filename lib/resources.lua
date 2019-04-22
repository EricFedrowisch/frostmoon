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
local fnt_dir = res_dir .. os_sep  .. "fnt"
--Tables of supported image types
local img_types_supported = {["png"] = true, ["tga"] = true}
local fnt_types_supported = {["ttf"] = true}
local snd_types_supported = {["wav"] = true, ["mp3"] = true, ["ogg"] = true, ["oga"] = true, ["ogv"] = true}

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
         img_name = v:gsub(img_dir .. os_sep, "")
         imgs[img_name] = love.graphics.newImage(v)
      end
   end
   return imgs
end

--Resize all current images
local function resize_imgs(elements)
   local imgs = {} --Make list of unique imgs used
   for i,e in ipairs(elements) do --Iterate through elements
      if imgs[e] == nil then imgs[e] = e end --If img not in list then add it
   end
   --Store screen width and height for calculations
   local s_width, s_height = love.graphics.getWidth(), love.graphics.getHeight()
   for k, e in pairs(imgs) do --For each img...
      e.image = res.resize(e.image_initial, e.sre_x, e.sre_y, e.maintain_aspect_ratio)
   end
   love.graphics.setCanvas() --Important! Reset draw target to main screen.
end

--Resize an image file.
local function resize(img, sre_x, sre_y, maintain_aspect_ratio)
   --Store screen width and height for calculations
   local s_width, s_height = love.graphics.getWidth(), love.graphics.getHeight()
   local cnvs_width, cnvs_height = (s_width * sre_x), (s_height * sre_y)
   local cnvs = love.graphics.newCanvas(cnvs_width, cnvs_height)
   love.graphics.setCanvas(cnvs) --Make special canvas current draw target
   --Resize image
   local sx = cnvs_width/img:getWidth()
   local sy = cnvs_height/img:getHeight()
   love.graphics.draw(img, 0, 0, 0, sx, sy)
   love.graphics.setCanvas()
   img = love.graphics.newImage(cnvs:newImageData()) --Make new image from canvas ImageData
   cnvs = nil
   love.graphics.setCanvas() --Important! Reset draw target to main screen.
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
         snds[v:gsub(snd_dir .. os_sep, "")] = love.audio.newSource(v, "static")
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
         msx[v:gsub(msx_dir .. os_sep, "")] = function () return love.audio.newSource(v, "stream") end --Returning function here to keep memory cost low.
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

local function load_resources(dir)
   local res = {}
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
   return res
end
------------------------------------------

return load_resources(res_dir)
