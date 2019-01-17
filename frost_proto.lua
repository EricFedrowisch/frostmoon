--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------

--"Table of Contents" for exports of the module
local exports = {} --Temp storage for exported functionality
local function export()
   return {
      component_prototype = exports.component_prototype,
          }
end

--UUID Requires here
local socket = require("socket")
local uuid = require("uuid")
uuid.randomseed(socket.gettime()*10000)
------------------------------------------

local Component = {}

--Check if target is a valid and properly initialized Component
function Component:valid_component(target)
   if target ~= nil then
      if type(target) == "table" then
         if _G.frostmoon.components[target.component_type] then
            return true
         end
      end
   end
   return false
end

function Component:receive_msg(msg)
   local response = nil
   if self.event_types ~= nil then
      if self.event_types[msg.type] then
         response = self.event_types[msg.type](self,msg)
      end
   end
   return response
end

function Component:direct_msg(target, msg)
   local response = nil
   if Component:valid_component(target) then
         response = target:receive_msg(msg)
   end
   return response
end

function Component:uuid_msg(uuid, msg)
   local response = nil
   if Component:valid_component(_G.frostmoon.instances._uuid[uuid]) then
      response = _G.frostmoon.instances._uuid[uuid]:receive_msg(msg)
   end
   return response
end

function Component:broadcast(msg)
   local responses = {}
   for k,v in pairs(_G.frostmoon.instances._uuid) do
      responses[k]=v:receive_msg(msg)
   end
   return responses
end

function Component:broadcast_type(type, msg)
   local responses = {}
   if _G.frostmoon.instances[type] ~= nil then
      for k,v in pairs(_G.frostmoon.instances[type]) do
         responses[k]=v:receive_msg(msg)
      end
   end
   return responses
end

function Component:broadcast_up(msg)
   local response = nil
   local current_container = self._container
   while (response == nil and current_container ~= nil) do
      if current_container.component_type ~= nil then
         response = current_container:receive_msg(msg)
      end
      current_container = current_container._container
   end
   return response
end

function Component:broadcast_down(msg)
   local responses = {}
   for k,v in pairs(self) do
      if Component:valid_component(v) then
         responses[v._uuid]=v:receive_msg(msg)
      end
   end
   return responses
end

function Component:broadcast_lateral(msg)
   local responses = {}
   if self._container ~= nil then
      for k,v in pairs(self._container) do
         if v ~= self then
            if Component:valid_component(v) then
               responses[v._uuid]=v:receive_msg(msg)
            end
         end
      end
   end
   return responses
end

function Component:query_state(var)
   return self[var]
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
         if k ~= "_container" and k ~= "self" and k ~= "__index" then
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

function Component:valid_ctype(component_type)
   return _G.frostmoon.components[component_type]
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
   if Component:valid_ctype(args.component_type) then
      setmetatable(obj, {__index=_G.frostmoon.components[args.component_type]})
      obj._uuid = uuid()
      _G.frostmoon.instances._uuid[obj._uuid]=obj --Register UUID
      _G.frostmoon.instances[args.component_type][obj._uuid] = obj --Keep track of instances for Broadcasts
      obj._container = container
      local defaults = _G.frostmoon.components[args.component_type].defaults
      if defaults then
         for k,v in pairs(defaults) do obj[k]=v end
      end
   end
   for k,v in pairs(args) do
      if type(v) == "table" then
         obj[k]=Component:new(v, obj)
      else
         obj[k]=v
      end
   end
   return obj
end
exports.component_prototype = Component

return export()
--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
