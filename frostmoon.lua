local exports = {} --Temp storage for exported functionality
--Table of Contents for the module
local function export()
   return {new = exports.new,
           components = exports.components,
           d = exports.d --Debug
          }
end

------------------------------------------

local components = require("load_components")
local d = require("frost_debug")
exports.components = components
exports.d = d


--Takes a table of arguements and returns a table of components using those args
local function new(args)
   obj = {}
   d.tprint(args)
   obj.args, obj.unused = args, args --Store original args as unused args too
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
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
--------------------------------------------------------
return export()
