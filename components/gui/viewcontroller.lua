--[[ViewController controls input and rendering of Frostmoon objects.]]
local debug = false
--local debug = true

local ViewController = {}

ViewController.defaults = {
   ["listeners"] = {},  --Registered listeners to receive events
   ["elements"] = {},   --Registered components to draw to screen
   ["_hover_over"] = {}, --Internal table of objects the mouse or touch is "hovering" over.
   ["_hover_events"] = {["mousemoved"] = true, ["touchmoved"]=true} --Table to check for event types that can trigger "hovering"
}

--Draw list of elements to screen in z axis render order
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
   for i, z in ipairs(z_layer) do
      for n, e in ipairs(z) do
         if e.visible == true then
            if e.draw_image == true then
               if e.image ~= nil then --Rem after rect fix
                  love.graphics.draw(e.image, e.x, e.y, e.r, e.sx, e.sy)
               end --Rem after rect fix
            else
               if e.draw ~= nil and type(e.draw) == "function" then --Checks overkill here?
                  e:draw()
               end
            end
         end
      end
   end
end

--Pass message to list of registered listeners.
function ViewController:pass_msg(msg)
   for i,listener in ipairs(self.listeners) do --Pass to listeners
      listener:receive_msg(msg)
   end
end

--Get events from queue and handle them or dispatch them to listeners.
function ViewController:update(dt)
   local event = q:use()
   if debug and event then d.tprint(event) end --Print events if debug == true
   if event == nil then  --If there are no events do heartbeat dt
      event = {["type"] = "heartbeat"}
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

--Check for collisions among rects of registered listeners for a UI event.
function ViewController:check_collisions(msg)
   for i, obj in ipairs(self.listeners) do --For each listener...
      if obj.rect ~= nil then                --If they have a rect component
         if obj.rect["z"] > 0 then             --If the rect z axis > 0... (bc reasons?)
            if obj.rect:inside(msg.args.x, msg.args.y) then  --If the event (x,y) inside event's rect area...
               obj:receive_msg(msg)                            --Tell object
               if self._hover_events[msg.args["type"]] ~= nil then  --If msg type is one to trigger "hover over" event
                  self._hover_over[#self._hover_over + 1] = obj       --Add object to list of hovered over objects
               end
            end
         end
      end
   end
   local msg_hover_end = {["type"] = "hover_end", ["dt"] = msg.dt} --Make mouse over end message to send to pertinent objects
   local msg_hover_cont = {["type"] = "hover_cont", ["dt"] = msg.dt} --Make mouse over continues message to send to pertinent objects
   local i, size = 1, #self._hover_over
   while i <= size do
      if not self._hover_over[i].rect:inside(msg.args.x, msg.args.y) then
         self._hover_over[i]:receive_msg(msg_hover_end)
         self._hover_over[i] = self._hover_over[size]
         size = size - 1
      else
         self._hover_over[i]:receive_msg(msg_hover_cont)
         i = i + 1
      end
   end
end

function ViewController:register(obj)
   if obj.component_type ~= "gui.element" then
      self:register_listener(obj)
   end
   if obj.component_type == "gui.element" then
      self:register_element(obj)
   end
   for k,v in pairs(obj) do --Go through all values of obj...
      if type(v) == "table" then   --if table then check...
         if v.component_type ~= nil then --If component...
            if v.component_type == "gui.element" then --If element
               self:register_element(v)   --Register the element
            end
         end
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
   res.resize_imgs(self.elements)
   self:pass_msg(msg)
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
   --TOUCH--
   ["touchmoved"]=function(self, msg) self:check_collisions(msg) end,
   ["touchpressed"]=function(self, msg) self:check_collisions(msg) end,
   ["touchreleased"]=function(self, msg) self:check_collisions(msg) end,
   --KEYBOARD--
   ["keypressed"]=function(self, msg) end,
   ["keyreleased"]=function(self, msg) end,
   ["textedited"]=function(self, msg) end,
   ["textinput"]=function(self, msg) end,
}

return ViewController
