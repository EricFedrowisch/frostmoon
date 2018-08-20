local exports = {} --Temp storage for exported functionality
--Table of Contents for the module
local function export()
   return {new = exports.new,
           components = exports.components,
           d = exports.d
          }
end

------------------------------------------

local components = require("load_components")
local d = require("frost_debug")
exports.components = components
exports.d = d


--Takes a table of arguements and returns a table of components using those args
local function new(self, args)
   obj = {}
   obj.args, obj.unused = args, args --Store original args as unused args too
   for k,v in pairs(args) do --For each arg, try to use it
      if (v.isComponent) and components[v.componentType] then
            obj[k], obj.unused.k = components[v.componentType]:new(v)
      else
         for n,p in pairs(v) do --If not component...
            if obj[n] then obj.unused[n] = p else obj[n] = p end
         end
      end
   end
  return obj
end
exports.new = new
--------------------------------------------------------
return export()
--[[
testObj = {}

testObj.a = nil
testObj.b = true
testObj.c = 123
testObj.d = "test"
testObj.e = "userdata type NEEDED HERE" --#TODO: Need simple userdata to test here
testObj.f = function (x) return x+1 end
testObj.g = "Need thread type here" --#TODO:Test thread needed here
testObj.h = {a,b,c}

testComponent = {["isComponent"] = true}
testComponent.b = true
testComponent.c = 123
testComponent.d = "test"
--d.line()
testObj.testComponent = components.object
print(testObj.testComponent.a)
--d.line()
testObj.testComponent = components.test1
print(testObj.testComponent.a)
--d.line()
--[[
d.line()
frostObj = new{testObj}
for k,v in pairs(testObj) do
  print(k,v)
end
d.line()
print(testObj.f(2))
d.line()
print(testObj.testComponent.a)
d.line()
print(testObj.unused)
d.line()
]]
