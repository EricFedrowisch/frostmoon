--[[
View object for storing rendering info
]]
local View = {}

View.defaults = {
   ["x"] = 0,
   ["y"]= 0,
   ["z"] = 1,
   ["width"] = 100,
   ["height"] = 100,
   ["is_image"] = true,
   ["r"] = 0,
}

function View:init(new_args)
   if new_args.image_initial == nil then
      if new_args.image then
         self.image_initial = new_args.image
         self.width  = new_args.image:getWidth()
         self.height = new_args.image:getHeight()
      end
   end
   return self
end

return View
