local f=require("frostmoon")
local d = require("frost_debug")

local new_args = {
   ["component_type"]="data.object",
   ["embedded_table"]= {"table entry 1","table entry 2","table entry 3"},
   ["subcomponent"]= {
      ["component_type"]="gui.button",
   }
}
test_obj = f:new(new_args)
d.tprint(test_obj)
