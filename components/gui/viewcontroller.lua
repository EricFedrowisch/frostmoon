--[[ViewController controls input and rendering of Frostmoon objects.]]
local ViewController = {}

ViewController.defaults = {

}

ViewController.event_types = {
   ["init"]=function(self, msg) print("Init ViewController") end,
}

return ViewController
