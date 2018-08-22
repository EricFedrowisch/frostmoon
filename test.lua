--os.execute("clear")
local f = require("frostmoon")
local d = f.d
test_args = {}

test_args.a = nil
test_args.b = true
test_args.c = 123
test_args.d = "test"
test_args.e = "userdata type NEEDED HERE" --#TODO: Need simple userdata to test here
test_args.f = function (x) return x+1 end
test_args.g = "Need thread type here" --#TODO:Test thread needed here
------------------------------------------
test_component = {["is_component"] = true, ["component_type"] = "object"}
test_component.b = true
test_component.c = 123
test_component.d = "test"
test_args.test_component = test_component
------------------------------------------

test_obj= {}
test_obj = f.new(test_args)
d.tprint(test_obj.test_component)

------------------------------------------
