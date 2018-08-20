--os.execute('clear')
local lfs = require("lfs")
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
--[[
#TODO: Give local environment?
#TODO: Add a before/after comparison of the global Environment to raise warnings
if components add to global namespace accidently
#TODO: Add CPath searcher stuff too
]]

local function split(str, sep)
   local t={}
   if sep == nil then sep = "%s" end --Default to whitespace
   for str in string.gmatch(str, "([^"..sep.."]+)") do
      t[#t+1] = str
   end
   return t
end

local function load_components(dir, recurse, components)
   local components = components or {}
   local files, dirs = {}, {}
   package.path = package.path .. ";" .. dir .. os_sep .. "?.lua"
   for i in lfs.dir(dir) do
      if (i ~= ".") and (i ~= "..") then --#TODO:This work on Windows & Linux?
         local f = dir .. os_sep .. i
         if lfs.attributes(f,"mode") == "file" then
            local parse = {f:match("(.-)([^\\/]-([^\\/%.]+))$")} --String MAAAAAAGIC!
            if (parse[3]:lower() == 'lua') and (parse[2] ~= arg[0]) then
               files[#files+1]=f
            end
         end
         if lfs.attributes(f,"mode") == "directory" then dirs[#dirs+1]=f end
      end
   end
   for i,file in ipairs(files) do
      local f = split(file,os_sep) --#TODO: UGLY. Ineffcient. Replace!
      local f = split(f[#f],".")
      local f = f[1]
      components[f]=require(f)
   end
   for i,dir in ipairs(dirs) do
      components = load_components(dir, true, components)
   end
   return components
end

------------------------------------------
--[[Exercising the code here]]--
local original_cwd = lfs.currentdir()
local target_dir = lfs.currentdir() .. os_sep .. "components" .. os_sep
lfs.chdir(target_dir)
local components = load_components(lfs.currentdir(), true)
lfs.chdir(original_cwd)
return components
