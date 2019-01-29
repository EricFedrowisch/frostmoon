--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
local uuid = require "uuid"
local Queue = {}

function Queue:new(size)
   local q = {}
   setmetatable(q , {__index = Queue}) --Make Queue instance inherit from Queue
   q.elements = {}
   q.read = 1 --Next element to read, internal. Leave alone
   q.size = size
   q.written = size --Internal write variable. Leave alone
   q.next_write = nil --Commit is the last position written to
   q.last_op = "init"
   q.updated = false
   return q
end

--Add and element to the Q, growing the Q size if needed.
function Queue:add(msg)
   msg._uuid = uuid()
   self.updated = true
   if self.cascade then --If you have an overflow q, then add to that not this.
      self.cascade:add(msg)
      self.last_op = "add"
   else
      local add = (self.written + 1) % self.size
      if add == 0 then add = self.size end --Needed bc Lua's 1st element is 1 not 0
      if self.last_op == "add" and add == self.read then
         --We have a problem, time to grow
         self.cascade = self:new(self.size * 2) --Make a new, bigger Q
         self.cascade:add(msg)
         self.last_op = "add"
         return
      end
      self.elements[add] = msg
      self.written = add
      self.next_write = (self.written + 1) % self.size
      if self.next_write == 0 then self.next_write = self.size end
      self.last_op = "add"
   end
end

function Queue:grow(read_pos)
   self.elements = self.cascade.elements
   self.read = read_pos or 1
   self.written = self.cascade.written
   self.last_op = "use"
   self.size = self.cascade.size
   if self.cascade.cascade ~= nil then
      self.cascade = self.cascade.cascade
   else
      self.cascade = nil
   end
end

--Use/process next element of Q
function Queue:use()
   self.updated = true
   local msg = nil
   if self.last_op ~= "stop" then
      msg = self.elements[self.read]
      if self.read == self.written then
         self.last_op = "stop"
         if self.cascade ~= nil then self:grow() end
      else
         self.last_op = "use"
         self.read = (self.read + 1) % self.size
         if self.read == 0 then self.read = self.size end --Needed bc Lua's 1st element is 1 not 0
      end
   end
   return msg
end

--Look at (next + n) element without advancing the Q.
function Queue:peek(nth)
   local n = nth or 0
   if self.last_op == "stop" then return nil end --"stop" op means no further Q
   if self.last_op == "init" then return self.elements[self.read] end --redundant here to cover "init"?
   local abs = math.abs(self.read - self.written)
   if n > abs and self.cascade ~= nil then
      return self.cascade:peek(n-abs-1)
   end
   local element = nil
   if abs < n then
      element = nil
   else
      local peek = (self.read + n) % self.size
      if peek == 0 then peek = self.size end --Needed bc Lua's 1st element is 1 not 0
      element = self.elements[peek]
   end
   return element
end

--Peek through elements in Q, returning table of elements that returned true
--when passed to function "fun".
function Queue:search(filter, ...)
   local hits = {}
   if filter ~= nil then --Gotta provide a function that returns a boolean
      local n = 0
      local peek = self:peek(n)
      while peek ~= nil do
         peek = self:peek(n)
         if peek ~= nil then
            if filter(peek, ...) then hits[#hits+1] = peek end
         end
         n = n + 1
      end
   end
   return hits
end

--Split a Q into 2 Qs based on an element filter function and return a table of the resulting Qs
function Queue:split(filter, ...)
   local a, b = {}, {}
   if filter ~= nil then --Gotta provide a function that returns a boolean
      local n = 0
      local peek = self:peek(n)
      while peek ~= nil do
         peek = self:peek(n)
         if peek ~= nil then
            if filter(peek, ...) then
               a[#a+1] = peek
            else
               b[#b+1] = peek
            end
         end
         n = n + 1
      end
   end
   --Make two new Qs
   local q_a = Queue:new(#a*2)
   local q_b = Queue:new(#b*2)
   q_a.written = #a
   q_b.written = #b
   q_a.elements = a
   q_b.elements = b
   return q_a, q_b
end

--Merge two Qs using a simple merge where b becomes a's tail. Optionally merge using function.
function Queue:merge(a, b, fun, ...)
   local merged = Queue:new(a.size + b.size)
   if fun ~= nil then
      merged = fun(a, b, ...)
   else
      local n = 0
      local peek = a:peek(n)
      while peek ~= nil do
         merged:add(peek)
         n = n + 1
         peek = a:peek(n)
      end
      n = 0
      peek = b:peek(n)
      while peek ~= nil do
         merged:add(peek)
         n = n + 1
         peek = b:peek(n)
      end
   end
   return merged
end

--Check if Q has been changed since last update call.
function Queue:update()
   if self.updated then
      self.updated = false
      return true
   end
   return false
end

--Return Q which has had function called on all its elements.
function Queue:map(fun, ...)
   local map_q = self:new(self.size)
   local n = 0
   local peek = self:peek(n)
   while peek ~= nil do
      local mapped = fun(peek, ...)
      map_q:add(mapped)
      n = n + 1
      peek = self:peek(n)
   end
   return map_q
end

return Queue
