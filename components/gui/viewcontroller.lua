--[[ViewController controls input and rendering of Frostmoon objects.]]
local d = require("frost_debug")
local ViewController = {}

ViewController.defaults = {
   ["listeners"] = {},
   ["views"] = {},
   ["mouse_over"] = {}
}

function ViewController:draw()
   for i, view in ipairs(self.views) do
      if view.is_image then --If simple image then
         self.love.graphics.draw(view.image, view.x, view.y) --Draw it
      else --Else not simple image then..
         self.love.graphics.draw(view.image, view.x, view.y)
      end
   end
end

function ViewController:update()
   local event = self.q:use()
   while event ~= nil do
      --If message is one you handle...
      --d.tprint(event)
      if self.event_types[event.type] then --Then handle it
         self:receive_msg(event)
      else --If not event you handle then...
         for i,listener in ipairs(self.listeners) do --Pass to listeners
            listener:receive_msg(event)
         end
      end
      event = self.q:use() --Get next event
   end
end

function ViewController:check_collisions(msg)
   for i, obj in ipairs(self.listeners) do
      if obj.rect ~= nil then
         if obj.rect["z"] > 0 then
            if obj.rect:inside(msg.args.x, msg.args.y) then
               obj:receive_msg(msg)
               self.mouse_over[#self.mouse_over + 1] = obj
            end
         end
      end
   end
   local msg_mouseover_end = {["type"] = "mouseover_end"}
   local i, size = 1, #self.mouse_over
   while i <= size do
      if not self.mouse_over[i].rect:inside(msg.args.x, msg.args.y) then
         self.mouse_over[i]:receive_msg(msg_mouseover_end)
         self.mouse_over[i] = self.mouse_over[size]
         size = size - 1
      else
         i = i + 1
      end
   end
end

function ViewController:register_obj(obj)
   self.listeners[#self.listeners + 1] = obj --Add object to listeners
   self.views[#self.views + 1] = obj.view  --Add view
end


ViewController.event_types = {
   --WINDOW--
   ["focus"]=function(self, msg) self.focus = msg.args["focus"] end,
   ["resize"]=function(self, msg) end,
   ["visible"]=function(self, msg) self.visible = msg.args["visible"] end,
   --MOUSE--
   ["mousefocus"]=function(self, msg) self.mousefocus = msg.args["mousefocus"] end,
   ["mousemoved"]=function(self, msg) self:check_collisions(msg) end,
   ["mousepressed"]=function(self, msg) self:check_collisions(msg) end,
   ["mousereleased"]=function(self, msg) self:check_collisions(msg) end,
   ["wheelmoved"]=function(self, msg) end,
   --KEYBOARD--
   ["keypressed"]=function(self, msg) end,
   ["keyreleased"]=function(self, msg) end,
   ["textedited"]=function(self, msg) end,
   ["textinput"]=function(self, msg) end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self:check_collisions(msg) end,
   ["touchreleased"]=function(self, msg) self:check_collisions(msg) end,
}

return ViewController
