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
          }
end

local Queue = {}
exports.queue = Queue

--Make queues inherit from Component
setmetatable(Queue , {__index = f.Component})

function Queue:new(size, obj)
   local q = obj or {} --Either make new Queue or use whatever is in obj
   setmetatable(q , {__index = Queue}) --Make Queue instance inherit from Queue
   q.head = q.head or 1 --Either use old head or make new one at index 1
   q.tail = q.tail or size --Either use odl tail or make new one at size

   return q
end

--Look at next element without popping it off the Q
function Queue:peek()
   local peek = nil
   if self.head ~= nil then
      return head
   end
end

--Add and element to the tail of the Q, growing the Q size if needed.
function Queue:add(msg)
end

--Process/pop next element of Q
function Queue:next(msg)
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
function Queueu:map(fnctn)
end

return export()
