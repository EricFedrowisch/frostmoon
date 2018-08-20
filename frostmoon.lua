

local components = require("load_components")

------------------------------------------
local exports = {} --Temp storage for exported functionality

--Table of Contents for the module
local function export()
   return {new = exports.new,
           use = exports.use
          }
end

--Use arguements, creating components as needed
local function use(obj, key, value)
   --nil, boolean, number, string, userdata, function, thread, and table
   if (value.isComponent) then
      value = new(value) --Do special component init here
   end
   obj[key] = value
end
exports.use = use

--Takes a table of arguements and returns a table of components using those args
local function new(args)
   obj = {}
   obj.args, obj.unused = args, args --Store the original args and unused args
   for k,v in pairs(args) do --For each arg, try to use it
      if (use(obj,k,v)) then obj.unused.k = nil end
   end
  return obj
end
exports.new = new
--------------------------------------------------------
local d = require("debug")
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
