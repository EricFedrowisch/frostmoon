--State class for storing states of FSM.
--Copyright Jun. 27th, 2019 Eric Fedrowisch All rights reserved.
local State = {}

State.defaults = {
   ["name"] = nil,   --State name as string
   ["enter"] = nil,  --Function to run when entering this state
   ["exit"] = nil,   --Function to run when exiting this state
   ["during"] = nil, --Function to run while in this state during heartbeat events.
   ["in_state"] = false,  --Boolean for whether State is FSM's current state or not
   ["vars"] = {},    --Table of state variables
}

function State:init(new_args)--(fsm, name, enter, exit, during)
   self.name = new_args.name
   self.enter = new_args.enter or nil  --Function to run when entering this state
   self.exit = new_args.exit or nil   --Function to run when exiting this state
   self.during = new_args.during or nil --Function to run while in this state during heartbeat events.
   self.vars = new_args.vars or {}    --Table of state variables
   self:error_checks()
end

function State.transition(self, args) --Called when transitioning in and out of state
   if not self.in_state then --If not in state then enter state
      if self.enter ~= nil then self.enter(args) end
      self._container.current = self.name --Tell fsm you are done with transition code and are now current state
   else                      --Else if in state then exit state
      if self.exit ~= nil then self.exit(args) end
   end
   self.in_state = not self.in_state --Toggle in_state boolean to reflect transition
end

--Make sure state is initialized properly and meets the minimum assumed operating parameters
function State:error_checks()
   if self._container == nil then error("State object without FSM") end
   if self.name == nil then error("State object without name") end
   if self.enter ~= nil then
      if type(self.enter) ~= "function" then error("State entry set to non-function") end
   end
   if self.exit ~= nil then
      if type(self.exit) ~= "function" then error("State exit set to non-function") end
   end
   if self.during ~= nil then if type(self.during) ~= "function" then
      error("State during set to non-function") end
   end
end

return State
