--[[ViewController controls input and rendering of Frostmoon objects.]]
local ViewController = {}

ViewController.defaults = {
}

function ViewController:init(args)
   self.s_width, self.s_height = love.window.getMode()
   self.scenes = {}      --Table of registered scenes
   self.hover_over = {} --Internal table of elements that are being "hovered over", indexed by z level
end

function ViewController:register_scene(scene)
   local scene_id = #self.scenes + 1 --Next available int
   self.scenes[scene_id] = scene --Make menu_screen the 1st scene
   scene.scene_id = scene_id
end

--Change scene by passing integer id for scene in self.scenes table
function ViewController:change_scene(scene_id)
   if self.scenes[scene_id] ~= nil then
      self.current_scene = nil
      self:end_hover()
      self.current_scene = self.scenes[scene_id]
   else
      error("Attempt to change scene with invalid scene id " .. scene_id)
   end
end

--End hover over status for all objects in scene.
function ViewController:end_hover()
   local msg_hover_end = {type = "hover_end"}   --Make hover over end message to send to pertinent objects
   for i, obj in pairs(self.hover_over) do --For each key, object pair in table of "hovered" objects...
      if obj.rect ~= nil then --If object has a rect, it cares about collisions
         obj:receive_msg(msg_hover_end)   --Tell object hover over ended
      end
   end
   --Remove all objects from table
   self.hover_over = {}
end

--Given a table with z values as keys, return a table of values in z order from highest to lowest. Suitable for
--giving objects on top (higher z) a chance to react to an event first.
function ViewController:get_event_ordered_elements(t)
   local alpha, omega, step = #t, 1, -1 --Name the list beggining, end and iter step
   local vals = {}
   for i = alpha, omega, step do
      for _,v in ipairs(t[i]) do table.insert(vals, v) end
      i = i + step
   end
   return vals
end

--Given a table with z values as keys, return a table of values in z order lowest to highest. Suitable for
--drawing objects with objects on top (higher z) after objects beneath them.
function ViewController:get_draw_ordered_elements(t)
   local alpha, omega, step = 0, #t, 1 --Name the list beggining, end and iter step
   local vals = {}
   for i = alpha, omega, step do
      if t[i] then
         for _,v in ipairs(t[i]) do table.insert(vals, v) end
      end
      i = i + step
   end
   return vals
end

function ViewController:draw()
   --Get elements of current scene
   local elements = self.current_scene.elements
   --Iterate through list ordered by
   for i, e in ipairs(self:get_draw_ordered_elements(elements)) do
      if e.visible == true then e:draw() end --If element is visible then draw it
   end
   --if _G.draw_debug then self:draw_debug() end
end

--Pass message to list of registered listeners for scene. Message passed to objs
--with highest z first. Scene id arg is int key to self.scenes table. Defaults to current scene
function ViewController:tell_scene_msg(msg, scene_id)
   local scene = self.scenes[scene_id] or self.current_scene
   local listeners = scene.listeners
   for i, l in ipairs(self:get_event_ordered_elements(listeners)) do
      if msg.handled ~= 1 then --If msg not handled (in blocking fashion) then...
         l:receive_msg(msg)
      else --Else if msg.handled == 1 then...
         break --Break out of loop
      end
   end
   return msg.handled
end

--Get events from queue and handle them or dispatch them to listeners.
function ViewController:update(dt)
   local event = q:use() --Get next event from the queue
   if event == nil then  --If there are no events do heartbeat event
      event = {type = "heartbeat"}
   end
   --Process all events
   while event ~= nil do --While there are still events...
      event.dt = dt --Mark event with delta time passed to update function
      --If message is one you handle...
      if self.event_types[event.type] then --Then handle it
         self:receive_msg(event)
      else --If not event you handle then...
         self:tell_scene_msg(event) --Pass it to listeners
      end
      event = q:use() --Get next event
   end
end

--Check for UI event collisions among rects of registered listeners.
function ViewController:check_collisions(msg)
   local listeners = self.current_scene.listeners
   local current_hover = {}
   for i, l in ipairs(self:get_event_ordered_elements(listeners)) do
      if msg.handled ~= 1 then --If msg not handled (in blocking fashion) then...
         if l.rect ~= nil then --If obj has rect component...
            if l.rect:inside(msg.args.x, msg.args.y) then --If the event (x,y) inside rect's area...
               table.insert(current_hover, l) --Add obj to hovered over list
               l:receive_msg(msg) --Tell obj allowing it to potentially handle msg
            end
         end
      else --Else if msg.handled == 1 then...
         break --Break out of loop
      end
   end
   --Update hover over status, either telling each object its hover over has continued or ended
   if #self.hover_over > 0 then --If there are objects hovered over...
      local msg_hover_end = {type = "hover_end", dt = msg.dt}   --Make hover over end message to send to pertinent objects
      local msg_hover_cont = {type = "hover_cont", dt = msg.dt} --Make hover over continues message to send to pertinent objects
      for i, l in ipairs(self.hover_over) do
         if l.rect ~= nil then --If object has a rect...(shouldn't need this. Being safe)
            if not l.rect:inside(msg.args.x, msg.args.y) then --If not inside
               l:receive_msg(msg_hover_end)  --Tell object hover over ended
            else                               --Else
               l:receive_msg(msg_hover_cont)  --Tell object hover over continues
               table.insert(current_hover, l) --Add obj to hovered over list
            end
         end
      end
   end
   self.hover_over = current_hover --Update hover over list to contain new and still hovered over
end

--#TODO:Rewrite resize code.
--Maybe mark images with screen height and width they are sized for to avoid repetition of work
--Elements not in scene may not get resized with this current code
function ViewController:resize(msg)
   local old_width, old_height = self.s_width, self.s_height
   self.s_width, self.s_height = love.window.getMode()
   print("Dimension Changed")
   print("Width Proportion", self.s_width/old_width)
   print("Height Proportion", self.s_height/old_height)
   for id, scene in ipairs(self.scenes) do
      local elements = self:get_draw_ordered_elements(scene.elements)
      res.resize_imgs(elements)
      self:tell_scene_msg(msg, id)
   end

end


function ViewController:draw_debug()
   local listeners = self:get_draw_ordered_elements(self.current_scene.listeners)
   local elements = self:get_draw_ordered_elements(self.current_scene.elements)
   love.graphics.setColor(1, 0, 0, 1)
   for i,v in ipairs(listeners) do
      if v.component_type == "Gui.Rect" then
         love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
      end
   end
   --[[
   love.graphics.setColor(1, 0, 0, 1)
   for _,l in ipairs(self:get_draw_ordered_elements(listeners)) do
      if l.rect ~= nil then
         local r = l.rect
         love.graphics.rectangle("line", r.x, r.y, r.width, r.height )
      end
   end

   love.graphics.setColor(0, 1, 0, 1)
   for _,e in ipairs(self:get_draw_ordered_elements(elements)) do
      if e.rect ~= nil then
         local r = e.rect
         love.graphics.rectangle("line", r.x, r.y, r.width, r.height )
      end
   end
   ]]
   love.graphics.setColor(1, 1, 1, 1)
end


ViewController.event_types = {
   --WINDOW--
   focus = function(self, msg) self.focus = msg.args.focus end,
   resize = function(self, msg) self:resize(msg) end,
   visible = function(self, msg) self.visible = msg.args.visible end,
   --MOUSE--
   mousefocus = function(self, msg) self.mousefocus = msg.args.mousefocus end,
   mousemoved = function(self, msg) self:check_collisions(msg) end,
   mousepressed = function(self, msg) self:check_collisions(msg) end,
   mousereleased = function(self, msg) self:check_collisions(msg) end,
   wheelmoved = function(self, msg) end,
   --TOUCH--
   touchmoved = function(self, msg) self:check_collisions(msg) end,
   touchpressed = function(self, msg) self:check_collisions(msg) end,
   touchreleased = function(self, msg) self:check_collisions(msg) end,
}

return ViewController
