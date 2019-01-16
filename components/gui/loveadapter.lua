--[[Adapter between Frostmoon library and the Löve portions of the app.]]
local Adapter = {}

function Adapter.init(self, love)
   if not love then error("Löve Adapter not given Löve instance.") end
   self.love_vars = {}
   self.love = love
   for k,v in pairs(self.love) do
      if type(v) == "table" then
         self:_map_love_table(k,v)
      elseif type(v) == "function" then
         self.event_types[tostring(k)] =
            function(self, msg)
               local vals = {}
               if msg.args then
                  vals = {v(unpack(msg.args))}
               else
                  vals = {v()}
               end
               return vals
            end
      else
         self.love_vars[k] = v
      end
   end
end

function Adapter._map_love_table(self, prefix, t)
   local prefix = tostring(prefix) -- Function name prefix, ie "window" of "window.getSize()"
   for k, v in pairs(t) do
      local event = table.concat({prefix, ".", tostring(k)})
      self.event_types[event] =
         function(self, msg)
            local vals = {}
            if msg.args then
               vals = {v(unpack(msg.args))}
            else
               vals = {v()}
            end
            return vals
         end
   end
end

function Adapter.get_love_var(self, var)
   return nil or self.love_vars[var]
end

Adapter.event_types = {
   ["init"]=function(self, msg) self:init(msg["love"]) end,
   ["get_var"]=function(self, msg) return self:get_love_var(msg["var"]) end,
}

return Adapter
