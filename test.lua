--os.execute("clear")
local f = require("frostmoon")
local d = require("frost_debug")
test_args = {}

--test_args.a = nil
test_args.b = true
test_args.c = 123
--test_args.d = "test"
--test_args.e = "userdata type NEEDED HERE" --#TODO: Need simple userdata to test here
test_args.f = function (x) return x+1 end
test_args.g = "Need thread type here" --#TODO:Test thread needed here
------------------------------------------
test_component = {}
test_component.component_type = "data.object"
test_component.b = true
test_component.c = 123
test_component.d = "test"
------------------------------------------
bad_component = {}
bad_component.component_type = "does.not.exist"
bad_component.val1 = false
------------------------------------------
test_args.test_component = test_component
test_args.test_table = {"tab1","tab2","tab3"}
test_args.bad_component = bad_component
------------------------------------------

test_obj= {}
test_obj = f.new(test_args, test_obj)
print("TEST OBJECT:")
d.line()
d.tprint(test_obj)
print(test_obj, "TestObj Memory Location")
print(test_obj.test_component._container, "Test Component Memory Location")
--print(test_obj.test_component)
--d.tprint(test_obj.test_component)

------------------------------------------
