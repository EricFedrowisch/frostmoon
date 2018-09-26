os.execute("clear")

frostmoon = require("frostmoon")
local f = frostmoon
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
local test_obj= {}
print(test_obj, "TestObj")
d.line()
------------------------------------------
test_obj = f.new(test_args, test_obj)
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
print(test_obj.component._container, "Component Container", test_obj == test_obj.component._container)
print(test_obj.component.subcomponent._container, "Subcomponent Container", test_obj.component == test_obj.component.subcomponent._container)
d.line()
------------------------------------------
