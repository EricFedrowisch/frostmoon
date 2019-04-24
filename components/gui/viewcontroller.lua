--[[ViewController controls input and rendering of Frostmoon objects.]]
local debug = false
--local debug = true

local ViewController = {}

ViewController.defaults = {}

function ViewController:init(new_args)
   self.listeners = {}   --Table of registered listeners to receive events
   self.elements = {}    --Table of elements to draw to screen
   self._hover_over = {} --Internal table of elements that are being "hovered over"
end

--Draw list of elements to screen in z axis render order
function ViewController:draw()
   --First sort elements by z axis render layer
   local z_layer = {}
   for k, e in pairs(self.elements) do
      local z = e.z or 1 --z is e.z or 1 if e.z is nil
      if z_layer[z] == nil then z_layer[z] = {} end --If entry for z axis coordinate doesn't exist yet, make it
      z_layer[z][#z_layer[z]+1] = e --Put element in the next entry in that z coordinate.
   end
   for i, z in ipairs(z_layer) do
      for n, e in ipairs(z) do
         if e.visible == true then e:draw() end
      end
   end
end

--Pass message to list of registered listeners.
function ViewController:pass_msg(msg)
   for k,listener in pairs(self.listeners) do --Pass to listeners
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
         for k, listener in pairs(self.listeners) do --Pass to listeners
            listener:receive_msg(event)
         end
      end
      event = q:use() --Get next event
   end
end

--Check for UI event collisions among rects of registered listeners.
function ViewController:check_collisions(msg)
   for k, obj in pairs(self.listeners) do --For each listener...
      if obj.rect ~= nil then                --If they have a rect component
         if obj.rect:inside(msg.args.x, msg.args.y) then  --If the event (x,y) inside event's rect area...
            obj:receive_msg(msg)                            --Tell object
            self._hover_over[obj] = obj       --Add object to table of hovered over objects
         end
      end
   end
   self:update_hover(msg) --Call hover update
end

--Check if hover over status for objects has changed because of UI event.
function ViewController:update_hover(msg)
   local msg_hover_end = {["type"] = "hover_end", ["dt"] = msg.dt} --Make hover over end message to send to pertinent objects
   local msg_hover_cont = {["type"] = "hover_cont", ["dt"] = msg.dt} --Make hover over continues message to send to pertinent objects
   for k, c in pairs(self._hover_over) do --For each key, component pair in table of "hovered" objects...
      if not c.rect:inside(msg.args.x, msg.args.y) then --If not inside component's rect...
         self._hover_over[k]:receive_msg(msg_hover_end)   --Tell object hover over ended
         self._hover_over[k] = nil                        --Remove object from table
      else                                              --Else
         self._hover_over[k]:receive_msg(msg_hover_cont)  --Tell object hover over continues
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
   self.listeners[obj] = obj --Add object to listeners
end

function ViewController:register_element(obj) --Adds object that has a on-screen drawn image
   self.elements[obj] = obj --Add object to elements
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
