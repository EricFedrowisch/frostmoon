if package.config:sub(1,1) == "/" then os.execute("clear") end

local q= require("frost_queue")
local d = require("frost_debug")
local rand = math.random

local last_integrity = 0
local last_insert = 0

local qt = nil --Queue  to be exercised

--Show state of Queue
local function state(qt)
   d.line()
   d.tprint(qt)
end

--Setup initial conditions
local function setup(verbose)
   qt = q:new(10)
   if verbose then state(qt) end
end

--check integrity
local function check_integrity(use)
   if use ~= nil then
      assert(use == last_integrity + 1, "Data Integrity Error")
   end
end

local function exercise_add(last_insert)
   qt:add(last_insert+1)
end


local function main_test(verbose)
   local ops = {
      function () check_integrity( qt:use() ) end, --Use and check integrity
      function () exercise_add(last_insert) end
   }
   local max_tests = 10 --How many random operations to do
   local current_test = 1
   while current_test <= max_tests do
      local op_num = rand(#ops)
      ops[op_num]()
      state(qt)
      current_test = current_test + 1
   end
end

local verbose = true
setup(verbose)
main_test(verbose)
