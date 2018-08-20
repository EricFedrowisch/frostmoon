------------------------------------------

local exports = {} --Temp storage for exported functionality

--Table of Contents for the module
local function export()
   return {iprint = exports.iprint,
           kprint = exports.kprint,
           line = exports.line,
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
------------------------------------------
return export()
