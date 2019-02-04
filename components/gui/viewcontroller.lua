--[[ViewController controls input and rendering of Frostmoon objects.]]
local debug = false
local ViewController = {}

ViewController.defaults = {
   ["listeners"] = {},  --Registered listeners to receive events
   ["views"] = {},      --Registered components to draw to screen
   ["_mouse_over"] = {} --Internal table of objects the mouse is over.
}

function ViewController:draw()
   for i, view in ipairs(self.views) do --#TODO: Make views have a love.drawable to replace view.image here.
      if view.is_image == true then
         love.graphics.draw(view.image, view.x(), view.y())
      else
         view:draw()
      end
   end
end

function ViewController:update(dt)
   local event = q:use()
   if debug and event then
      d.tprint(event)
   end

   while event ~= nil do
      event.dt = dt
      --If message is one you handle...
      if self.event_types[event.type] then --Then handle it
         self:receive_msg(event)
      else --If not event you handle then...
         for i,listener in ipairs(self.listeners) do --Pass to listeners
            listener:receive_msg(event)
         end
      end
      event = q:use() --Get next event
   end
end

function ViewController:check_collisions(msg)
   for i, obj in ipairs(self.listeners) do
      if obj.rect ~= nil then
         if obj.rect["z"] > 0 then
            if obj.rect:inside(msg.args.x, msg.args.y) then
               obj:receive_msg(msg)
               self._mouse_over[#self._mouse_over + 1] = obj
            end
         end
      end
   end
   local msg_mouseover_end = {["type"] = "mouseover_end"}
   local i, size = 1, #self._mouse_over
   while i <= size do
      if not self._mouse_over[i].rect:inside(msg.args.x, msg.args.y) then
         self._mouse_over[i]:receive_msg(msg_mouseover_end)
         self._mouse_over[i] = self._mouse_over[size]
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

function ViewController:resize()
   self.s_width, self.s_height = love.window.getMode()
end

ViewController.event_types = {
   --WINDOW--
   ["focus"]=function(self, msg) self.focus = msg.args["focus"] end,
   ["resize"]=function(self, msg) self:resize(msg) end,
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
