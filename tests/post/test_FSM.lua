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
   local exit_a = function() exited_a = true end
   local while_a = function() during_a = true end

   --State B test vars and functions
   local entered_b = false
   local exited_b = false
   local during_b = false
   local enter_b = function() entered_b = true end
   local exit_b = function() exited_b = true end
   local while_b = function() during_b = true end

   --State C test vars and functions
   local entered_c = false
   local exited_c = false
   local during_c = false
   local enter_c = function() entered_c = true end
   local exit_c = function() exited_c = true end
   local while_c = function() during_c = true end

   --State D test vars and functions
   local entered_d = false
   local exited_d = false
   local during_d = false
   local enter_d = function() entered_d = true end
   local exit_d = function() exited_d = true end
   local while_d = function() during_d = true end

   --Register the states
   a_fsm:register_state("a", enter_a, exit_a, while_a)
   a_fsm:register_state("b", enter_b, exit_b, while_b)
   a_fsm:register_state("c", enter_c, exit_c, while_c)
   a_fsm:register_state("d", enter_d, exit_d, while_d)

   --State A can go to B only
   a_fsm:register_transition("a_to_b", "a", "b")
   --State B can go to C or D
   a_fsm:register_transition("b_to_c", "b", "c")
   a_fsm:register_transition("b_to_d", "b", "d")
   --State C can go to A or B
   a_fsm:register_transition("c_to_a", "c", "a")
   a_fsm:register_transition("c_to_b", "c", "b")
   --State D no exit from state

   --To test all paths: A -> B -> C ->A -> B -> C-> B -> D then D goes nowhere

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
      assert.is.truthy(entered_a)
   end)

   it("Ignore erroneous input in state a", function()
      a_fsm:get_input("nonsense")
      assert.are.equal(a_fsm.current, "a")
   end)

   it("Test FSM get tick in state a", function()
      assert.is.falsy(during_a)
      a_fsm:get_input("tick")
      assert.is.truthy(during_a)
   end)

   it("Test FSM transitioned to b", function()
      a_fsm:get_input("a_to_b")
      assert.are.equal(a_fsm.current, "b")
      assert.is.truthy(exit_a)
      assert.is.truthy(entered_b)
   end)

   it("Ignore erroneous input in state b", function()
      a_fsm:get_input("nonsense")
      assert.are.equal(a_fsm.current, "b")
   end)

   it("Test FSM get tick in state b", function()
      assert.is.falsy(during_b)
      a_fsm:get_input("tick")
      assert.is.truthy(during_b)
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B
   it("Test FSM transition to c", function()
      a_fsm:get_input("b_to_c")
      assert.are.equal(a_fsm.current, "c")
      assert.is.truthy(exit_b)
      assert.is.truthy(entered_c)
   end)

   it("Ignore erroneous input in state c", function()
      a_fsm:get_input("nonsense")
      assert.are.equal(a_fsm.current, "c")
   end)

   it("Test FSM get tick in state c", function()
      assert.is.falsy(during_c)
      a_fsm:get_input("tick")
      assert.is.truthy(during_c)
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C
   it("Test FSM transition back to a", function()
      a_fsm:get_input("c_to_a")
      assert.are.equal(a_fsm.current, "a")
      assert.is.truthy(exit_c)
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C -> A
   it("Test FSM transition back to b", function()
      a_fsm:get_input("a_to_b")
      assert.are.equal(a_fsm.current, "b")
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C -> A -> B
   it("Test FSM transition back to c", function()
      a_fsm:get_input("b_to_c")
      assert.are.equal(a_fsm.current, "c")
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C -> A -> B -> C
   it("Test FSM transition back to b", function()
      a_fsm:get_input("c_to_b")
      assert.are.equal(a_fsm.current, "b")
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C -> A -> B -> C -> B
   it("Test FSM transition to d", function()
      a_fsm:get_input("b_to_d")
      assert.are.equal(a_fsm.current, "d")
      assert.is.truthy(entered_d)
   end)

   it("Ignore erroneous input in state d", function()
      a_fsm:get_input("nonsense")
      assert.are.equal(a_fsm.current, "d")
      assert.is.falsy(exited_d)
   end)

   it("Test FSM get tick in state d", function()
      assert.is.falsy(during_d)
      a_fsm:get_input("tick")
      assert.is.truthy(during_d)
   end)
   --To test all paths: A -> B -> C -> A -> B -> C -> B -> D then D goes nowhere
   --Progress so far:   A -> B -> C -> A -> B -> C -> B -> D
end)
