if package.config:sub(1,1) == "/" then os.execute("clear") end

frostmoon = require("frostmoon")
local f = frostmoon
local d = require("frost_debug")
local test_args = {}
local s = require("socket")

--test_args.a = nil
test_args.b = true
test_args.c = 123
--test_args.d = "test"
--test_args.e = "userdata type NEEDED HERE" --#TODO: Need simple userdata to test here
test_args.f = function (x) return x+1 end
test_args.g = "Need thread type here" --#TODO:Test thread needed here
------------------------------------------
local component = {}
component.component_type = "data.object"
component.b = true
component.c = 123
component.d = "test"
component.def1 = "Override default 1"
------------------------------------------
local bad_component = {}
bad_component.component_type = "does.not.exist"
bad_component.val1 = false
------------------------------------------
local subcomponent = {}
subcomponent.component_type = "gui.button"
subcomponent.d = "this is a subcomponent"
------------------------------------------
test_args.component = component
test_args.test_table = {"tab1","tab2","tab3"}
test_args.bad_component = bad_component
test_args.component.subcomponent = subcomponent
------------------------------------------

d.line()
------------------------------------------
local test_obj= {}
test_obj = f.Component:new(test_args, test_obj)
print("TEST OBJECT:")
d.line()
------------------------------------------
d.tprint(test_obj)
d.line()
------------------------------------------
print(test_obj, "TestObj Memory Location")
print(test_obj.component, "Test Component Memory Location")
print(test_obj.component.subcomponent, "Test Subcomponent Memory Location")
d.line()
------------------------------------------
print(test_obj.component.new==f.Component.new)
--[[
print(test_obj.component._container, "Component Container")
print(test_obj.component.subcomponent._container, "Subcomponent Container")
d.line()
------------------------------------------
print("test_obj == test_obj.component._container", test_obj == test_obj.component._container)
print("test_obj.component == test_obj.component.subcomponent._container", test_obj.component == test_obj.component.subcomponent._container)
d.line()
------------------------------------------
print("Object Instances By Type:")
d.kprint(f.instances); print("")
for k,v in pairs(f.instances) do d.kprint(v) end
print(d.kcount(f.instances["data.object"]))
d.line()
------------------------------------------
collectgarbage ( "collect")--Do a full garbage collection.
collectgarbage ( "collect")--No, but seriously...FULL gc.
--collectgarbage ( "collect")
print("Mem Usage Before Destruction:", d.mem_use())
print("Object Destruction Test:")
test_obj.component._destroy_self(test_obj.component.self)
test_obj.component = nil
for k,v in pairs(f.instances) do d.kprint(v) end
print(d.kcount(f.instances["data.object"]))
--d.tprint(f.instances)
collectgarbage ( "collect")
print("Mem Usage After Destruction:", d.mem_use())
d.line()
print("test_obj._uuid", test_obj._uuid)
print("test_obj._container",test_obj._container)
]]
