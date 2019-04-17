--[[ViewController controls input and rendering of Frostmoon objects.]]
local debug = false
local ViewController = {}

ViewController.defaults = {
   ["listeners"] = {},  --Registered listeners to receive events
   ["elements"] = {},      --Registered components to draw to screen
   ["_mouse_over"] = {} --Internal table of objects the mouse is over.
}

function ViewController:draw()
   --First sort elements by z axis render layer
   local z_layer = {}
   for i, e in ipairs(self.elements) do
      local z = 1
      if e.z ~= nil then
         z = e.z
         if z_layer[z] == nil then z_layer[z] = {} end --If entry for z axis coordinate doesn't exist yet, make it
      end
      z_layer[z][#z_layer[z]+1] = e --Put element in the next entry in that z coordinate.
   end
   for i, z in ipairs(z_layer) do --#TODO: Make elements respect z axis here...
      for n, e in ipairs(z) do
         if e.draw_image == true then
            love.graphics.draw(e.image, e.x, e.y, e.r, e.sx, e.sy)
         else
            e:draw()
         end
      end
   end
end

function ViewController:pass_msg(msg)
   for i,listener in ipairs(self.listeners) do --Pass to listeners
      listener:receive_msg(msg)
   end
end

function ViewController:update(dt)
   local event = q:use()
   if debug and event then
      d.tprint(event)
   end
   if event == nil then  --If there are no events do heartbeat dt
      event = {["type"] = "heartbeat"}
   end

   while event ~= nil do
      event.dt = dt
      --if event.type == "heartbeat" then print("Beat", dt) end
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
   local msg_mouseover_end = {["type"] = "mouseover_end"} --Make mouse over end message to send to pertinent objects
   local msg_mouseover_cont = {["type"] = "mouseover_cont", ["dt"] = msg.dt} --Make mouse over continues message to send to pertinent objects
   local i, size = 1, #self._mouse_over
   while i <= size do
      if not self._mouse_over[i].rect:inside(msg.args.x, msg.args.y) then
         self._mouse_over[i]:receive_msg(msg_mouseover_end)
         self._mouse_over[i] = self._mouse_over[size]
         size = size - 1
      else
         self._mouse_over[i]:receive_msg(msg_mouseover_cont)
         i = i + 1
      end
   end
end

function ViewController:register_listener(obj) --Adds object that listens for events
   self.listeners[#self.listeners + 1] = obj --Add object to listeners
   self.elements[#self.elements + 1] = obj.view  --Add view
end

function ViewController:register_element(obj) --Adds object that has a on-screen drawn image
   self.elements[#self.elements + 1] = obj --Add object to elements
   self.elements[#self.elements + 1] = obj.view  --Add view
end

function ViewController:resize(msg)
   self.s_width, self.s_height = love.window.getMode()
   self:pass_msg(msg)
   res.resize_imgs(self.elements)
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
