--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
Library of debug functions. Meant to be independant from Frostmoon.
--]]
------------------------------------------

local exports = {} --Temp storage for exported functionality

--Table of Contents for the module
local function export()
   return {iprint  = exports.iprint, --Print a table's ipairs
           kprint  = exports.kprint, --Print all a table's keys, value pairs
           vprint  = exports.vprint, --Print just a table's ipair values.
           mprint  = exports.mprint, --Print metatable of table.
           line    = exports.line,     --Print a line to divide up output visually
           tprint  = exports.tprint, --Print a table's values recursively indented
           ttest   = exports.ttest,   --Return boolean of table-ness and error message if need
           kcount  = exports.kcount, --Return an int count of table's keys or nil if not table
           mem_use = exports.mem_use, --Return int number of bytes currently used by Lua's memory footprint
           clear   = exports.clear,  --Clear the terminal output
           timestamp = exports.timestamp, --Return current timestamp string
           get_file_extension = exports.get_file_extension, --Return ".xxx" file extension string
          }
end

-------------------------------------------
--[[Debug Functions Here]]--
local function table_test(t)
   local is_table, error_msg = false, nil
   if t ~= nil and type(t) == 'table' then
      is_table = true
   else
      if t == nil then
         error_msg = "nil"
      elseif type(t) ~= 'table' then
         error_msg = tostring(t) .. " of type " .. type(t) .. " is not a table."
      end
   end
   return is_table, error_msg
end
exports.ttest = table_test

local function vprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for i,v in ipairs(t) do print(v) end
   else
      print(ttest[2])
   end
end
exports.vprint = vprint

local function iprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for i,v in ipairs(t) do print(i,v) end
   else
      print(ttest[2])
   end
end
exports.iprint = iprint

local function kprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for k,v in pairs(t) do print(k,v) end
   else
      print(ttest[2])
   end
end
exports.kprint = kprint

local function line(text)
   local line = "--------------------------------------------\n"
   if text ~= nil then print(line .. tostring(text)) end
   print(line)
end
exports.line = line


local function _tprint (t, shift, container)
   local container = container or nil
   if t ~= nil and type(t) == 'table' then
      shift = shift or 0
      for k, v in pairs(t) do
         local str = string.rep("   ", shift) .. tostring(k) .. " = "
         if type(v) == "table"  and t ~= container and k ~= "_container" and k ~= "self" then
            print(str)
            exports._tprint(v, shift+1, t)
         else
            print(str .. tostring(v))
         end
      end
   else
      if t == nil then
         print("nil")
      elseif type(t) ~= 'table' then
         error(tostring(t) .. " of type " .. type(t) .. " is not a table.")
      end
   end
end
exports._tprint = _tprint

local function tprint(t, label)
   exports.line(label)
   _tprint(t)
   if getmetatable(t) then
      exports.mprint(t)
   else
      exports.line()
   end
end
exports.tprint = tprint

local function mprint(t)
   exports.line("Metatable:")
   local ttest = {table_test(getmetatable(t))}
   if ttest[1] then
      for k,v in pairs(getmetatable(t)) do
         print(tostring(k) .. " = " .. tostring(v))
         if type(v) == "table" then exports._tprint(v, 1, v) end
      end
   else
      print(ttest[2])
   end
   exports.line()
end
exports.mprint = mprint

local function kcount(t)
   local c = nil
   if type(t) == "table" then
      c = 0
      for k,v in pairs(t) do c = c + 1 end
   end
   return c
end
exports.kcount = kcount

local function mem_use()
   return (collectgarbage("count") * 1024) --Mem Usage in Bytes
end
exports.mem_use = mem_use

local function clear()
   if not os.execute("clear") then
      os.execute("cls")
   elseif not os.execute("cls") then
      for i = 1,25 do
         print("\n\n")
      end
   end
end
exports.clear = clear

local function get_file_extension(filename)
   if type(filename) ~= "string" then
      return nil
   else
      return filename:match("[^.]+$") --Get file extension
   end
end
exports.get_file_extension = get_file_extension

local function timestamp()
   return os.date('%I:%M:%S%p-%b-%d-%Y')
end
exports.timestamp = timestamp

------------------------------------------
return export()