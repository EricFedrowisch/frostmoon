--[[
#TODO: Give local environment?
#TODO: Add a before/after comparison of the global Environment to raise warnings
if components pollute global namespace accidently
#TODO: Add CPath searcher stuff too
]]

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

local function component_lookup(str_path)
   local t, load_str={}, 'return components'
   for str in string.gmatch(str_path, "([^"..'.'.."]+)") do t[#t+1] = str end
   for i,str in ipairs(t) do str = str:gsub('%W','') end --Scrub non-alphanumeric
   for i,v in pairs(t) do load_str = load_str .. '["' .. v ..  '"]' end
   local results, errors = loadstring(load_str)
   if errors then print("Error:", errors, "load_str:", load_str) end
   return results()
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
      local up = tostring(f[#f - 1])
      local f = split(f[#f],".")
      local f = f[1]
      --if not components[up] then components[up] = {} end
      --components[up][f]=require(f)
      components[f]=require(f)
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
local original_cwd = lfs.currentdir()
local target_dir = lfs.currentdir() .. os_sep .. "components" .. os_sep
lfs.chdir(target_dir)
exports.components = load_components(lfs.currentdir(), true)
lfs.chdir(original_cwd)
d.tprint(exports.components)
--return components
return export()
