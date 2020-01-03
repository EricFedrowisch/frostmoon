if _G.f_debug ~= nil then _G.f_debug.more_info("Post-conditions test scripts run.") end
require 'busted.runner'()
expose("Inheritance functionality tests #component #inheritance", function()
   it("Test of testy tests", function()
      assert.is.truthy(true)
   end)
end)
_G.f_debug.reset_busted()
