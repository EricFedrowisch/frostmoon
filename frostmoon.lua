--[[
#TODO:Add warnings for:component already exists, global namespace polluted by loaded
      component
#TODO: Add CPath searcher & loading capabilities
]]
local component_dir = "components" --Directory from which to recursively load components
local lfs = require("lfs")
local os_sep = package.config:sub(1,1) --Get the OS file path seperator
local d = require("frost_debug")
local exports = {} --Temp storage for exported functionality

--"Table of Contents" for exports of the module
local function export()
   return {
      new = exports.new,
      components = exports.components,
          }
end
------------------------------------------
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
   package.path = package.path .. ";" .. dir .. os_sep .. "?.lua" --Add to path for require
   for i in lfs.dir(dir) do
      if (i ~= ".") and (i ~= "..") then --#TODO:Check does this work on Windows, iOS & Linux?
         local f = dir .. os_sep .. i
         if lfs.attributes(f,"mode") == "file" then
            local parse = {f:match("(.-)([^\\/]-([^\\/%.]+))$")} --String MAAAAAAGIC!
            if (parse[3]:lower() == 'lua') and (parse[2] ~= arg[0]) then --If lua and not this script itself
               files[#files+1]=f
            end
         end
         if lfs.attributes(f,"mode") == "directory" then dirs[#dirs+1]=f end
      end
   end
   for i,file in ipairs(files) do
      local f = split(file,os_sep)
      local split_index = nil
      local name = split(f[#f],".");name = name[1];f[#f]=name --Get file name minus '.lua'
      for i,v in ipairs(f) do  --Find componet dir index
         if f[i] == component_dir then split_index = i; break end
      end
      for i,v in ipairs(f) do --Delete preceding path before
         if i < split_index then f[i] = nil end
      end
      local t = {}
      for i = split_index + 1,#f do t[#t+1] = f[i] end
      local path = table.concat(t,'.');
      components[path]=require(name)
      --Do component private variables here
      components[path]._type = path
      components[path]._load_path = file
   end
   for i,dir in ipairs(dirs) do
      components = load_components(dir, true, components)
   end
   return components
end


------------------------------------------

--Takes a table of arguements and returns a table of components using those args
local function new(args)
   obj = {}
   --d.tprint(args)
   obj.args, obj.unused = args, args --Store original args as unused args too
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
         d.tprint(components)
         if (v.is_component) and components[v.component_type] then
            obj[k], obj.unused.k = components[v.component_type].new(v)
         end
      else
         if obj[k] then obj.unused[k] = v else obj[k] = v end --Think more about parameter conlicts
      end
   end
  return obj
end
exports.new = new
------------------------------------------
--os.execute('clear')

--[[Exercising the code here]]--
orig_packagepath = package.path --Store package.path before
local original_cwd = lfs.currentdir()
local target_dir = lfs.currentdir() .. os_sep .. component_dir .. os_sep
lfs.chdir(target_dir)
exports.components = load_components(lfs.currentdir(), true)
lfs.chdir(original_cwd)
d.tprint(exports.components)
package.path = orig_packagepath --Restore package.path
return export()
