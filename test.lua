if package.config:sub(1,1) == "/" then os.execute("clear") end

local f = require("frostmoon")
local d = require("frost_debug")
local test_args = {}

local function setup(verbose)
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
   local lateral_component = {}
   lateral_component.component_type = "data.object"
   ------------------------------------------
   test_args.component = component
   test_args.lateral_component = lateral_component
   test_args.test_table = {"tab1","tab2","tab3"}
   test_args.bad_component = bad_component
   test_args.component.subcomponent = subcomponent
   ------------------------------------------
   test_obj= {}
   test_obj = f.Component:new(test_args, test_obj)
   if verbose then
      print("TEST OBJECT:")
      d.line()
      ------------------------------------------
      d.tprint(test_obj)
      d.line()
   end
end

local function contain_test(verbose)
   setup()
   if verbose then
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
   end
   assert(test_obj == test_obj.component._container)
   assert(test_obj.component == test_obj.component.subcomponent._container)
end

local function uuid_test(verbose)
   setup()
   if verbose then
      print("UUID TESTS:")
      print("Object Instances By Type:")
      d.kprint(f.instances); print("")
      for k,v in pairs(f.instances) do
         d.kprint(v)
      end
      d.line()
   end
   assert(f.instances ~= nil)
   for k,v in pairs(f.instances) do
      assert(k == v._uuid)
   end
end

local function msg_test(verbose)
   setup()
   d.line()
   local msg = {
      ["type"]="push"
   }
   local msg2 = {
      ["type"]="test"
   }
   local echo = {
      ["type"]="echo"
   }
   print("Receive Tests:")
   test_obj.component.subcomponent:receive_msg(msg)
   d.line()
   print("Direct Message Tests:")
   test_obj.component:direct_msg(test_obj.component.subcomponent,msg)
   test_obj.component:direct_msg(nosuchtarget,msg)
   d.line()
   print("Broadcast Test:")
   local broadcast = test_obj.component:broadcast(msg2)
   d.tprint(broadcast)
   local broadcast = test_obj.component:broadcast(echo)
   d.tprint(broadcast)
   print("Broadcast To Type Test:")
   local type_broadcast = test_obj.component:broadcast_type("data.object", echo)
   d.tprint(type_broadcast)
   print("Broadcast Up Test:")
   local broadcast_up = test_obj.component.subcomponent:broadcast_up(msg2)
   print(broadcast_up)
   print("Broadcast Down Test:")
   test_obj.component:broadcast_down(msg)
   print("Broadcast Lateral Test:")
   local lat = test_obj.component:broadcast_lateral(echo)
   d.tprint(lat)
   print("Query State Test:")
   local query = test_obj.component:query_state("c")
   print(query)
   query = test_obj.component:query_state(c) --just c doesn't exist bc key is actuall "c" as a string
   print(query)
   print(test_obj.component.c)
end

local function oop_test(verbose)
   setup()
   test_obj.component.subcomponent:push()
end


local function destroy_test(verbose)
   setup()
   collectgarbage ( "collect")--Do a full garbage collection.
   collectgarbage ( "collect")--No, but seriously...FULL gc.
   --collectgarbage ( "collect")
   local before, after = d.mem_use(), d.mem_use()
   if verbose then
      print("OBJECT DESTRUCTION TESTS:")
      print("Mem Usage Before Destruction:", before)
      print("Instances BEFORE destruction code invoked:")
      print("data.object Type count:",d.kcount(f.instances["gui.button"]))
      d.tprint(f.instances)
      d.line()
      print("Object Destruction Test:")
      print("Destroying: test_obj.component.subcomponent", test_obj.component.subcomponent.component_type)
   end
   test_obj.component.subcomponent:_destroy_self()
   test_obj.component.subcomponent = nil
   if verbose then
      print("data.object Type count:",d.kcount(f.instances["gui.button"]))
      print("Instances AFTER destruction code invoked:")
      d.tprint(f.instances)
   end
   collectgarbage ( "collect")
   collectgarbage ( "collect")
   after = d.mem_use()

   print("Before:", before, "After:", after)
   d.line()
end

local function q_add_setup(verbose)
   local q = require("frost_queue")
   local msgs = {"1st Add", "2nd Add", "3rd Add"}
   if verbose then
      print("Basic Non-Grow Required Q Test:")
      d.line()
      print("Init new Q:")
   end
   local test_q = q:new(3)
   if verbose then
      d.tprint(test_q)
      d.line()
      print("Add element...")
   end
   test_q:add(msgs[1])
   if verbose then
      d.tprint(test_q)
      d.line()
      print("Add element...")
   end
   test_q:add(msgs[2])
   if verbose then
      d.tprint(test_q)
      d.line()
      print("Add element...")
   end
   test_q:add(msgs[3])
   if verbose then
      d.tprint(test_q)
      d.line()
   end
   return test_q
end

local function q_test(verbose)
   local q = require("frost_queue")
   local test_q = q_add_setup(verbose)
   if verbose then
      d.tprint(test_q)
      d.line()
      print("Use Tests:")
   end
   local use = test_q:use()
   if verbose then
      print("Use 1st = ", use)
      d.tprint(test_q)
      d.line()
   end
   use = test_q:use()
   if verbose then
      print("Use 2nd = ", use)
      d.tprint(test_q)
      d.line()
   end
   use = test_q:use()
   if verbose then
      print("Use 3rd = ", use)
      d.tprint(test_q)
      d.line()
   end
   use = test_q:use()
   if verbose then
      print("Use Nonexistent 4th = ", use)
      d.tprint(test_q)
      d.line()
   end
   test_q:add("4th")
   if verbose then
      print("Adding 4th")
      d.tprint(test_q)
      d.line()
   end
   use = test_q:use()
   if verbose then
      print("Use 4th = ", use)
      d.tprint(test_q)
      d.line()
   end
   use = test_q:use()
   if verbose then
      print("Use Nonexistent 5th = ", use)
      d.tprint(test_q)
      d.line()
   end
end

local function q_overrun_setup(verbose)
   local q = require("frost_queue")
   local test_q = q_add_setup(verbose)
   test_q:add("4, 1st Overrun")
   if verbose then
      d.tprint(test_q)
      d.line()
   end
   test_q:add("5, 2nd Overrun")
   if verbose then
      d.tprint(test_q)
      d.line()
   end
   return test_q
end

local function q_peek_test(verbose)
   local test_q = queue_overrun_setup(verbose)
   print("Next + 0:",test_q:peek())
   d.line()
   print("Next + 1:",test_q:peek(1))
   d.line()
   print("Next + 2:",test_q:peek(2))
   d.line()
   print("Next + 3:",test_q:peek(3))
   d.line()
   print("Next + 4:",test_q:peek(4))
   d.line()
   print("Next + 5:",test_q:peek(5))
   d.line()
end

local function q_search_test(verbose)
   local test_q = q_overrun_setup(verbose)
   print("Find elements with 'Add' in them:")
   local hits = test_q:search(string.find, "Add")
   d.tprint(hits)
   print("Find elements with '1' in them:")
   local hits = test_q:search(string.find, "1")
   d.tprint(hits)
end

local function q_overrun_test(verbose)
   local test_q = queue_overrun_setup(verbose)
   local got = nil
   for i=1,5 do
      print("Use #" .. i)
      print("Got " .. tostring(test_q:use()))
      d.tprint(test_q)
      d.line()
   end
end

--contain_test(true)
--uuid_test(true)
--destroy_test(true)
--msg_test(true)
--q_test(true)
--q_peek_test(true)
--q_search_test(true)
--q_overrun_test(true)
