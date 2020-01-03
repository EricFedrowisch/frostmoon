--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
Library of debug functions. Meant to be (mostly) independant from FrostMoon.

Functions provided:
iprint,  Print a table's ipairs
kprint,  Print all a table's keys, value pairs
vprint,  Print just a table's ipair values.
mprint,  Print metatable of table.
line,    Print a line to divide up output visually
tprint,  Print a table's values recursively indented
ttest,   Return boolean of table-ness and error message if need
kcount,  Return an int count of table's keys or nil if not table
mem_use, Return int number of bytes currently used by Lua's memory footprint
clear,   Clear the terminal output
timestamp, Return current timestamp string
get_file_extension, Return ".xxx" file extension string
--]]
------------------------------------------
--Debug Globals.
_G.f_debug = {} --Global table for functions and flag variables
_G.arg={} --Gotta clear out the args for busted to work for some reason
_G.continue_busted = true
--Global Flag Variables
-- _G.f_debug.details  = false
_G.f_debug.details  = true
_G.f_debug.draw_debug = false
_G.f_debug.continuous = false --Whether to run during tests every cycle of main loop.
_G.f_debug.run_test_countdown = 1 --How many times to run during tests if not continuous
_G.f_debug.draw_touches = false --Whether to draw touches on touch screens
_G.f_debug.debug_events = false --Print out event messages
_G.f_debug_msg_uuids = {}

------------------------------------------
--System Debug Output
if _G.f_debug.details ~= false then
   print("OS: " .. _G.OS.os_name)
   print("OS Path Sep: ", _G.OS.sep)
   print("Filesystem fused: " .. tostring(_G.OS.is_fused))
   print("Source Path: ", _G.OS.source_path)
   print("FrostMoon lib files at: " .. _G.OS.lib)
   print("CWD: " .. _G.OS.cwd())
   print("Require path: " .. love.filesystem.getRequirePath())
   print("C Require path: " .. love.filesystem.getCRequirePath())
end

-------------------------------------------
--[[During Debug Function]]--
function _G.f_debug.during()
   if _G.f_debug.continuous ~= true then
      _G.f_debug.run_test_countdown = _G.f_debug.run_test_countdown - 1
   end
   if _G.f_debug.run_test_countdown >= 1 then
      exec("" .. _G.OS.sep  .. "tests" .. _G.OS.sep .. "during") --Run during test scripts
   end
end

function _G.f_debug.more_info(msg)
   if _G.f_debug.details ~= false then
      print(msg)
   end
end

function _G.f_debug.reset_busted()
   local clear = {
      'busted.environment',
      'busted.runner',
      'busted.context',
      'busted.execute',
      'busted.languages.en',
      'busted.modules.standalone_loader',
      'busted.utils',
      'busted.block',
      'busted.outputHandlers.base',
      'busted.outputHandlers.utfTerminal',
      'busted.modules.cli',
      'busted.core',
      'busted.modules.luacov',
      'busted',
      'busted.modules.output_handler_loader',
      'busted.modules.helper_loader',
      'busted.modules.filter_loader',
      'busted.modules.configuration_loader',
      'busted.status',
      'busted.options',
      'busted.compatibility'
   }
   for i,v in ipairs(clear) do
      package.loaded[v] = nil
   end
end


--[[Debug Functions Here]]--
function _G.f_debug.ttest(t)
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

function _G.f_debug.vprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for i,v in ipairs(t) do print(v) end
   else
      print(ttest[2])
   end
end

function _G.f_debug.iprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for i,v in ipairs(t) do print(i,v) end
   else
      print(ttest[2])
   end
end

function _G.f_debug.kprint(t)
   local ttest = {table_test(t)}
   if ttest[1] then
      for k,v in pairs(t) do print(k,v) end
   else
      print(ttest[2])
   end
end

function _G.f_debug.line(text)
   local line = "--------------------------------------------\n"
   if text ~= nil then print(line .. tostring(text)) end
   print(line)
end

local function _tprint (t, shift, container)
   local container = container or nil
   if t ~= nil and type(t) == 'table' then
      shift = shift or 0
      for k, v in pairs(t) do
         local str = string.rep("   ", shift) .. tostring(k) .. " = "
         if type(v) == "table"  and t ~= container and k ~= "_container" and k ~= "self" then
            print(str)
            _tprint(v, shift+1, t)
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

function _G.f_debug.tprint(t, label)
   _G.f_debug.line(label)
   _tprint(t)
   if getmetatable(t) then
      _G.f_debug.mprint(t)
   else
      _G.f_debug.line()
   end
end

function _G.f_debug.mprint(t)
   _G.f_debug.line("Metatable:")
   local ttest = {table_test(getmetatable(t))}
   if ttest[1] then
      for k,v in pairs(getmetatable(t)) do
         print(tostring(k) .. " = " .. tostring(v))
         if type(v) == "table" then _tprint(v, 1, v) end
      end
   else
      print(ttest[2])
   end
   _G.f_debug.line()
end

function _G.f_debug.kcount(t)
   local c = nil
   if type(t) == "table" then
      c = 0
      for k,v in pairs(t) do c = c + 1 end
   end
   return c
end

function _G.f_debug.mem_use()
   return (collectgarbage("count") * 1024) --Mem Usage in Bytes
end

function _G.f_debug.clear()
   if not os.execute("clear") then
      os.execute("cls")
   elseif not os.execute("cls") then
      for i = 1,25 do
         print("\n\n")
      end
   end
end

function _G.f_debug.get_file_extension(filename)
   if type(filename) ~= "string" then
      return nil
   else
      return filename:match("[^.]+$") --Get file extension
   end
end

function _G.f_debug.timestamp()
   return os.date('%I:%M:%S%p-%b-%d-%Y')
end
------------------------------------------
