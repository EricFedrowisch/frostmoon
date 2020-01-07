require 'busted.runner'()
expose("Finite State Machine tests #component #FSM", function()
   local fsm = _G.frostmoon.components["Data.FSM.FSM"]
   local state = _G.frostmoon.components["Data.FSM.State"]
   local a_fsm = FSM{}

   --State A test vars and functions
   local entered_a = false
   local exited_a = false
   local during_a = false
   local enter_a = function() entered_a = true end
   local enter_a = function() exited_a = true end
   local enter_a = function() during_a = true end

   --State B test vars and functions
   local entered_b = false
   local exited_b = false
   local during_b = false
   local enter_a = function() entered_b = true end
   local enter_a = function() exited_b = true end
   local enter_a = function() during_b = true end

   --State C test vars and functions
   local entered_c = false
   local exited_c = false
   local during_c = false
   local enter_a = function() entered_c = true end
   local enter_a = function() exited_c = true end
   local enter_a = function() during_c = true end

   --State D test vars and functions
   local entered_d = false
   local exited_d = false
   local during_d = false
   local enter_a = function() entered_d = true end
   local enter_a = function() exited_d = true end
   local enter_a = function() during_d = true end

   --Register the states
   a_fsm:register_state("a", entered_a, exited_a, during_a)
   a_fsm:register_state("b", entered_b, exited_b, during_b)
   a_fsm:register_state("c", entered_c, exited_c, during_c)
   a_fsm:register_state("d", entered_d, exited_d, during_d)

   --State A can go to B only
   a_fsm:register_transition("a_to_b", "a", "b")
   --State B can go to C or D
   a_fsm:register_transition("b_to_c", "b", "c")
   a_fsm:register_transition("b_to_d", "b", "d")
   --State C can go to A or B
   a_fsm:register_transition("c_to_a", "c", "a")
   a_fsm:register_transition("c_to_b", "c", "b")
   --State D no exit from state

   --Enable fsm. It should now be be in state a and ready to transition
   it("Test Creation", function()
      assert.is.truthy(fsm)
      assert.is.truthy(state)
      assert.is.truthy(a_fsm)
   end)

   it("Test FSM not enabled yet", function()
      assert.is.falsy(fsm.enabled)
   end)

   it("Assert that the default values are initialized and correct",function ()
      for k,v in pairs(fsm.defaults) do
         assert.are.equal(fsm.defaults[k], a_fsm[k])
      end
   end)

   it("Test FSM now enabled and in state a", function()
      a_fsm:enable("a")
      assert.is.truthy(a_fsm.enabled)
      assert.are.equal(a_fsm.current, "a")
   end)

end)
