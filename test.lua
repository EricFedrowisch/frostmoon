if package.config:sub(1,1) == "/" then os.execute("clear") end

local f = require("frostmoon")
local d = require("frost_debug")
local test_args = {}

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
print("CONTAINER TESTS:")
print(test_obj, "TestObj Memory Location")
print(test_obj.component, "Test Component Memory Location")
print(test_obj.component.subcomponent, "Test Subcomponent Memory Location")
------------------------------------------
print(test_obj.component._container, "Component Container")
print(test_obj.component.subcomponent._container, "Subcomponent Container")
------------------------------------------
print("test_obj == test_obj.component._container", test_obj == test_obj.component._container)
print("test_obj.component == test_obj.component.subcomponent._container", test_obj.component == test_obj.component.subcomponent._container)
d.line()
------------------------------------------
print("UUID TESTS:")
print("Object Instances By Type:")
d.kprint(f.instances); print("")
for k,v in pairs(f.instances) do
   d.kprint(v)
end
d.line()
------------------------------------------
print("OBJECT DESTRUCTION TESTS:")
collectgarbage ( "collect")--Do a full garbage collection.
collectgarbage ( "collect")--No, but seriously...FULL gc.
--collectgarbage ( "collect")
local before, after = d.mem_use(), d.mem_use()
print("Mem Usage Before Destruction:", before)
print("Instances BEFORE destruction code invoked:")
print("data.object Type count:",d.kcount(f.instances["gui.button"]))
d.tprint(f.instances)
d.line()
test_obj.component.subcomponent:push()
d.line()
print("Object Destruction Test:")
print("Destroying: test_obj.component", test_obj.component.component_type)
test_obj.component.subcomponent:_destroy_self()
test_obj.component.subcomponent = nil
print("data.object Type count:",d.kcount(f.instances["gui.button"]))
print("Instances AFTER destruction code invoked:")
d.tprint(f.instances)
for k,v in pairs(f.instances) do d.kprint(v) end
d.tprint(f.instances)
collectgarbage ( "collect")
after = d.mem_use()
print("Mem Usage After Destruction:", after)
print("Before:", before, "After:", after)
d.line()
print("test_obj._uuid", test_obj._uuid)
print("test_obj._container",test_obj._container)
