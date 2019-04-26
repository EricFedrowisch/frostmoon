--[[ViewController controls input and rendering of Frostmoon objects.]]
--local debug = false
local debug = true

local ViewController = {}

ViewController.defaults = {}

function ViewController:init(new_args)
   self.listeners = {}   --Table of registered listeners to receive events, indexed by z level
   self.elements = {}    --Table of elements to draw to screen, indexed by z level
   self.hover_over = {} --Internal table of elements that are being "hovered over", indexed by z level
end

--Draw list of elements to screen in z axis render order
function ViewController:draw()
   local z_vals = self:z_order(self.elements)
   for i, z in ipairs(z_vals) do
      for k, e in pairs(self.elements[z]) do --For all elements of a z value...
         if e.visible == true then e:draw() end --If element is visible then draw it
      end
   end
end

--Pass message to list of registered listeners.
function ViewController:pass_msg(msg)
   local z_vals = self:z_order(self.listeners)
   for i, z in ipairs(z_vals) do --Pass messages in z axis order...
      if msg.handled ~= 1 then --If msg not handled (in blocking fashion) then...
         for k, listener in pairs(self.listeners[z]) do --Pass to listeners in given z
            if msg.handled ~= 1 then --If msg not handled then...
               listener:receive_msg(msg) --Pass msg
            else --Else if msg.handled == 1 then...
               break --Break out of loop
            end
         end
      else --Else if msg.handled == 1 then...
         break --Break out of loop
      end
   end
end

--Get events from queue and handle them or dispatch them to listeners.
function ViewController:update(dt)
   local event = q:use() --Get next event from the queue
   if event == nil then  --If there are no events do heartbeat event
      event = {["type"] = "heartbeat"}
   end
   --Process all events
   while event ~= nil do --While there are still events...
      event.dt = dt --Mark event with delta time passed to update function
      --if debug and event then d.tprint(event) end --Print events if debug == true
      --If message is one you handle...
      if self.event_types[event.type] then --Then handle it
         self:receive_msg(event)
      else --If not event you handle then...
         self:pass_msg(event) --Pass it to listeners
      end
      event = q:use() --Get next event
   end
end

--Check for UI event collisions among rects of registered listeners.
function ViewController:check_collisions(msg)
   local z_vals = self:z_order(self.listeners, true) --Get z values in reverse order
   for i, z in ipairs(z_vals) do --Pass messages in z axis order...
      if msg.handled ~= 1 then --If msg not handled (in blocking fashion) then...
         for k, obj in pairs(self.listeners[z]) do --Pass to listeners in given z
            if msg.handled ~= 1 then --If msg not handled then...
               if self:check_collide(obj, msg) then
                  self.hover_over[z][obj] = obj --Add object to table of hovered over objects
                  obj:receive_msg(msg)
               end
            else --Else if msg.handled == 1 then...
               break --Break out of loop
            end
         end
      else --Else if msg.handled == 1 then...
         break --Break out of loop
      end
   end
   self:update_hover(msg) --Call hover update
end

function ViewController:check_collide(obj, msg)
   local collide = false
   local x, y = msg.args.x, msg.args.y
   if obj.rect ~= nil then --If they have a rect component
      if obj.rect:inside(x, y) then  --If the event (x,y) inside event's rect area...
         collide = true
      end
   end
   return collide
end

--Check if hover over status for objects has changed because of UI event.
function ViewController:update_hover(msg)
   local msg_hover_end = {["type"] = "hover_end", ["dt"] = msg.dt}   --Make hover over end message to send to pertinent objects
   local msg_hover_cont = {["type"] = "hover_cont", ["dt"] = msg.dt} --Make hover over continues message to send to pertinent objects
   local z_vals = self:z_order(self.hover_over)
   for i, z in ipairs(z_vals) do --Pass messages in z axis order...
      for k, obj in pairs(self.hover_over[z]) do --For each key, object pair in table of "hovered" objects...
         if obj.rect ~= nil then --If object has a rect, it cares about collisions
            if not obj.rect:inside(msg.args.x, msg.args.y) then --If not inside component's rect...
               self.hover_over[z][k]:receive_msg(msg_hover_end)   --Tell object hover over ended
               self.hover_over[z][k] = nil                        --Remove object from table
            else                                              --Else
               self.hover_over[z][k]:receive_msg(msg_hover_cont)  --Tell object hover over continues
            end
         end
      end
   end
end

--Given a table with z values as keys, return a non-sparse table of z values suitable for use with ipairs.
function ViewController:z_order(t, reverse)
   local z_vals = {} --Create an empty table for z values
   for z, v in pairs(t) do table.insert(z_vals, z) end --Insert all z values into table
   table.sort(z_vals) --Sort the z values.
   --If not reversed needed, the list at this stage will be returned
   if reverse then --If order should be reversed (for input event handling ie)...
      local reversed = {} --Make empty table
      for i = #z_vals, 1, -1 do --Iterate over z_vals in reverse (-1 step)
         reversed[#reversed+1] = z_vals[i] --Next element of reveresed is z_val[i]
      end
      z_vals = reversed --Set z_vals equal to new reversed list
   end
   return z_vals --Return non-sparse list of z values for use with ipairs
end

--Given z value, register that z as an index in all the ViewController tables
function ViewController:register_z_index(z)
   if z ~= nil then
      if self.listeners[z] == nil then self.listeners[z] = {} end --If entry for z axis coordinate doesn't exist yet, make it
      if self.hover_over[z] == nil then self.hover_over[z] = {} end --If entry for z axis coordinate doesn't exist yet, make it
      if self.elements[z] == nil then self.elements[z] = {} end
   end
end

--Register objects. Registers all elements in object's contents (non-recursively)
--Registers all non-element class objects as listeners.
function ViewController:register(obj)
   self:register_z_index(obj.z)
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
   local z = obj.z or 1
   self.listeners[z][obj] = obj --Add object to listeners
end

function ViewController:register_element(obj) --Adds object that has a on-screen drawn image
   local z = obj.z or 1
   self.elements[z][obj] = obj --Add object to elements
end

function ViewController:resize(msg)
   self.s_width, self.s_height = love.window.getMode()
   local z_vals = self:z_order(self.elements)
   for i, z in ipairs(z_vals) do --Pass messages in z axis order...
      res.resize_imgs(self.elements[z])
   end
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
