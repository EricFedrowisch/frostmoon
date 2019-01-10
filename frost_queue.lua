--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local f = require("frostmoon")

local exports = {} --Temp storage for exported functionality
local function export()
   return {
      queue = exports.queue,
      new = exports.queue.new,
          }
end

local Queue = {}
exports.queue = Queue

--Make queues inherit from Component
setmetatable(Queue , {__index = f.Component})

function Queue:new(size, obj)
   local q = obj or {} --Either make new Queue or use whatever is in obj
   setmetatable(q , {__index = Queue}) --Make Queue instance inherit from Queue
   q.read = q.read or 1 --Either use old read or make new one at index 1
   q.size = size
   q.write = q.write or q.size
   q.last_op = "init"
   return q
end

--Add and element to the Q, growing the Q size if needed.
function Queue:add(msg)
   local add = (self.write + 1) % self.size
   if add == 0 then add = self.size end --Needed bc Lua's 1st element is 1 not 0
   if self.last_op == "add" and add == self.read then
      --We have a problem, unhandled messages are being overwritten
      print("DEBUG STUB: INVOKE GROW HERE")
   end
   self[add] = msg
   self.write = add
   self.last_op = "add"
end

--Use/process next element of Q
function Queue:use()
   local msg = nil
   if self.last_op ~= "stop" then
      msg = self[self.read]
      if self.read == self.write then
         self.last_op = "stop"
      else
         self.last_op = "use"
      end
      self.read = (self.read + 1) % self.size
      if self.read == 0 then self.read = self.size end --Needed bc Lua's 1st element is 1 not 0
   end
   return msg
end

--Look at next nth element without advancing the Q. Default is next element.
function Queue:peek(n)
   
end

--Split a Q into 2 or more Qs based on a filter function and return a table of the resulting Qs
function Queue:split(q, filter)
end

--Merge two Qs using function or do a simple merge of b becomes a's tail if none given
function Queue:merge(a,b,fun)
end

--Doooo stuff?
function Queue:update()
end

--Return Q which has had fnctn called on all its elements. Elements may be transformed.
function Queue:map(fnctn)
end

return export()
