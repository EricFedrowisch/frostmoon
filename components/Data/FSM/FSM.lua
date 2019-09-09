--Finite State Machine Class.
--FSMs have a set of states that can have transitions between them. Transitions
--are triggered by inputs.
--Copyright Jun. 27th, 2019 Eric Fedrowisch All rights reserved.

local FSM = {}

 FSM.defaults = {
   ["states"] = {}, --Table of States
   ["transitions"] = {}, --Table of state transitions
   ["enabled"] = false, --Whether FSM is fully initialized and ready to go
   ["current"] = "", --Current state of FSM
   ["tick"] = "tick", --String input that triggers "during" method of current state
}

function FSM:register_state(name, enter, exit, during)
   if type(name) ~= "string" then error("State name not string") end
   local state_args = {
      ["component_type"] = "data.FSM.state",
      ["name"] = name,
      ["enter"] = enter,  --Function to run when entering this state
      ["exit"] = exit,   --Function to run when exiting this state
      ["during"] = during, --Function to run while in this state during heartbeat events.
   }
   local state = _G.f.new(state_args, self)
   self.states[name]=state
   self.transitions[name] = {}
end

function FSM:register_transition(input, start_state, end_state)
   if type(input) ~= "string" then error("Transition input name not string") end
   if not self.states[start_state] then error("No such start state " .. start_state) end
   if not self.states[end_state] then error("No such end state " .. end_state) end
   self.transitions[start_state][input]=end_state
end

function FSM:enable(initial_state, args)
   if self.states[initial_state] ~= nil then --If initial state legal...
      self.states[initial_state]:transition(args) --Then transition to that state
      self.current = initial_state
   else
      error("Attempt to enable FSM with invalid state " .. tostring(initial_state))
   end
   self.enabled = true
end

function FSM:get_input(input, args)
   if not self.enabled then error("FSM not enabled.") end
   if input ~= self.tick then
      if self.transitions[self.current] ~= nil then
         if self.transitions[self.current][input] ~= nil then
            self:transition(self.current, self.transitions[self.current][input], args)
         end
      end
   else
      if self.states[self.current] ~= nil then
         if self.states[self.current].during ~= nil then
            self.states[self.current].during(args)
         end
      end
   end
end

function FSM:transition(exit, start, args)
   self.states[exit]:transition()
   self.states[start]:transition()
end

return FSM
