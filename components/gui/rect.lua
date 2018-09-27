--[[
Rect object for storing/testing collisions. In Löve, Upper left corner of
screen is (0, 0)
]]
local exports= {} --Temp variable
local function new(args)
   local defaults = {["x"] = 0,
                     ["y"]= 0,
                     ["z"] = 0,
                     ["width"] = 100,
                     ["height"] = 100
                    }
-----------------------------------
   local obj = {}
   for k,v in pairs(args) do
      if type(v) ~= "table" then
         obj[k] = v
      else
         obj[k] = _G.frostmoon.new(v, obj)
      end
   end
   for k,v in pairs(defaults) do
      if obj[k] == nil then obj[k] = v end
   end
-----------------------------------
   return obj
end
exports.new = new

local function inside(self, x, y)
   return (x >= this.x and x <= (this.x + this.width)) and
          (y >= this.y and y <= (this.y + this.height))
end
exports.inside = inside

--"Table of Contents" for exports of the module
local function export()
   return {
      new = exports.new,
      inside = exports.inside,
          }
end

return exports
