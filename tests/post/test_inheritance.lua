--for i,v in pairs(arg) do print(i,v) end
arg={}
local busted = require 'busted.runner'
--for k,v in pairs(_G) do print(k,v) end
busted()
expose("Inheritance functionality tests #component #inheritance", function()
   local classA = _G.frostmoon.components["Inherit.A"]
   local classB = _G.frostmoon.components["Inherit.B"]
   it("Assert that A and B class prototypes exist", function()
      assert.is.truthy(classA)
      assert.is.truthy(classB)
   end)
   local a = A{} --Create a default instance of A
   local b = B{} --Create a default instance of B
   it("Assert that a and b exist", function()
      assert.is.truthy(a)
      assert.is.truthy(b)
   end)

   it("Assert that the default values are initialized and correct",function ()
      for k,v in pairs(classA.defaults) do
         assert.is.truthy(a[k])
         assert.are.equal(classA.defaults[k], a[k])
      end
      for k,v in pairs(classB.defaults) do
         assert.is.truthy(b[k])
         assert.are.equal(classB.defaults[k], b[k])
      end
   end)
   --
   it("Assert that the inherited functions are correct", function()
      assert.are.equal(a.testA(), b.testA()) --B should inherit A's function testA
   end)
   it("Assert that the default initialized values are different for each class", function()
      for k,v in pairs(a.defaults) do
         local a_val = a.defaults[k]
         local b_val = b.defaults[k]
         assert.are_not.equals(a_val, b_val)
      end
   end)
   it("A should not have any of B's functions", function ()
      local x = a.testB
      assert.is.falsy(x)
   end)
end)

--[[


local msg1 = " not nil and set to correct default"
assert(a.def1 == "Default 1 for A", "a.def1" .. msg1)
assert(a.def2 == 7, "a.def2" .. msg1)
assert(a.def3 == 9, "a.def3" .. msg1)
assert(b.def1 == "Default 1 for B", "b.def1" .. msg1)
assert(b.def2 == 5, "b.def2" .. msg1)

local msg2 = " class got correct parent "

assert(a.__parent == "Component", "a" .. msg2 .. "Component")



if _G.debug_modes.more_info then print("Inheritance tests run.") end
]]
