------------------------------------------

local exports = {} --Temp storage for exported functionality

--Table of Contents for the module
local function export()
   return {iprint = exports.iprint,
           kprint = exports.kprint,
           line = exports.line,
           tprint = exports.tprint
          }
end

-------------------------------------------
--[[Debug Functions Here]]--
local function iprint(t)
   for i,v in ipairs(t) do print(i,v) end
end
exports.iprint = iprint

local function kprint(t)
   for k,v in pairs(t) do print(k,v) end
end
exports.kprint = kprint

local function line()
   print("--------------------------------------------")
end
exports.line = line

local function tprint (t, shift)
   if t ~= nil and type(t) == 'table' then
      shift = shift or 0
      for k, v in pairs(t) do
         local str = string.rep("   ", shift) .. k .. " = "
         if type(v) == "table" then
            print(str)
            tprint(v, shift+1)
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
------------------------------------------
return export()
