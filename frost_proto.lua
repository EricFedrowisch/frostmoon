--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      component_prototype = exports.component_prototype,
      Message = exports.Message,
          }
end

--UUID Requires here
local socket = require("socket")
local uuid = require("uuid")
uuid.randomseed(socket.gettime()*10000)
------------------------------------------

local Component = {}

function Component:_receive_msg(msg)
   return nil
end

function Component:_direct_message(target, msg)
   return target:_receive_message(msg)
end

function Component:_broadcast(msg)
   local responses = {}
   for k,v in pairs(_G.frostmoon.instances._uuid) do
      responses[k]=self:_direct_message(v, msg) --Not sure oop syntax here works
   end
   return responses
end

function Component:_broadcast_up(msg)
   local response = nil
   local current_container = self._container
   while (response == nil and current_container ~= nil) do
      if current_container.component_type then
         response = current_container:_direct_message(msg)
      end
      current_container = current_container._container
   end
end

function Component:_broadcast_down(self, msg)
   return nil
end

function Component:_broadcast_lateral(self, msg)
   return nil
end

function Component:_query_state(target, var)
   return nil
end

function Component:_query_var(target, var)
   return nil
end

--[[
   Takes:
   -self parameter of object to destroy. Also recursively sets all the
    object's contents to nil. Only meant to be called by self, but could be
    (ab)used with targets other than self.
   Returns:
   -None
--]]
function Component:_destroy_self()
   if type(self) == "table" then
      if self.component_type then
         _G.frostmoon.instances[self.component_type][self._uuid]=nil
         _G.frostmoon.instances._uuid[self._uuid]=nil
      end
      for k,v in pairs(self) do
         if k ~= "_container" and k ~= "self" then
            if type(v) == "table" then
               if v.component_type then
                  v:_destroy_self()
               end
            end
            v = nil
         end
         if k == "_container" then --Delete container's reference to self
            for k,v in pairs(v) do
               if v == self then v = nil end
            end
         end
      end
   end
   self = nil
end
------------------------------------------
--[[
Takes:
   - args = table of arguements
   - optional container = container for components to pass messages upwards
Returns:
   - a table of components made using args
--]]
function Component:new(args, container)
   local obj = {}
   if _G.frostmoon.components[args.component_type] then
      obj._container = container
      setmetatable(obj, {__index=Component})
   end
   for k,v in pairs(args) do --For each arg, try to use it
      if type(v) == "table" then
         if _G.frostmoon.components[v.component_type] then --If existing component
            obj[k] = _G.frostmoon.Component:new(v)
            obj[k] = _G.frostmoon.components[v.component_type]:new(v) --then make it
            obj[k]._container = obj
            obj[k]._uuid = uuid()
            _G.frostmoon.instances._uuid[obj[k]._uuid]=obj[k] --Register UUID
            obj[k].self = obj[k]
            _G.frostmoon.instances[v.component_type][obj[k]._uuid] = obj --Keep track of instances for Broadcasts
         elseif  v.component_type == nil then --If table, but not component
            obj[k] = Component:new(v) --then call new
         end
      else --If not table, then not component
         obj[k] = v
      end
   end
  return obj
end

exports.component_prototype = Component


local Message = {}
exports.Message = Message

return export()
--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
