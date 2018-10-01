--[[
Rect object for storing/testing collisions. In Löve, Upper left corner of
screen is (0, 0)
]]

local _defaults = {
                     ["x"] = 0,
                     ["y"]= 0,
                     ["z"] = 0,
                     ["width"] = 100,
                     ["height"] = 100
                  }

local function _inside(self, x, y)
   return (x >= this.x and x <= (this.x + this.width)) and
          (y >= this.y and y <= (this.y + this.height))
end

local function new(args)

-- Generic object instantiation
-----------------------------------
   local obj = {}
   obj = _G.frostmoon.new(args, obj)
-----------------------------------
-- Assign class specific methods
   obj.inside = _inside
-----------------------------------
   return obj
end

local t = {}
t.new = new
t._defaults = _defaults

return t
