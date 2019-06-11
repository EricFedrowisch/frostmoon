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
           line    = exports.line,     --Print a line to divide up output visually
           tprint  = exports.tprint, --Print a table's values recursively indented
           ttest   = exports.ttest,   --Return boolean of table-ness and error message if need
           kcount  = exports.kcount, --Return an int count of table's keys or nil if not table
           mem_use = exports.mem_use, --Return int number of bytes currently used by Lua's memory footprint
           clear   = exports.clear,  --Clear the terminal output
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

local function line()
   print("--------------------------------------------")
end
exports.line = line

local function tprint (t, shift, container)
   local container = container or nil
   if t ~= nil and type(t) == 'table' then
      shift = shift or 0
      for k, v in pairs(t) do
         local str = string.rep("   ", shift) .. tostring(k) .. " = "
         if type(v) == "table"  and t ~= container and k ~= "_container" and k ~= "self" then
            print(str)
            tprint(v, shift+1, t)
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
exports.tprint = tprint

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
------------------------------------------
return export()
