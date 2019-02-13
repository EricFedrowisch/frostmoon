--[[Class for drawing simple text tooltips to render to screen]]

local Tooltip = {}

Tooltip.defaults = {
   ["text"] = "Default tooltip text",
   ["font"] = "default",
   ["visible"] = false, --Whether to draw tooltip
   ["time_over"] = 0, --How long has the mouse/finger been over the tooltip's object
   ["threshold"] = 15, --Tooltip pop up threshold
   ["float_height"] = 20, --How many pixels above container should tooltip be rendered
   ["text_color"] = {1,0,0,1}
}

function Tooltip:draw()
   if self.visible then
      --Draw self
      love.graphics.setColor(unpack(self.text_color))
      local x, y = 0, 0
      if type(self.x) == "function" then x = self.x() else x = self.x  end
      if type(self.y) == "function" then y = self.y() else y = self.y  end
      love.graphics.draw(self.drawable_text, x, y)
      love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
   end
end

function Tooltip:popup_timer(dt)
   --if dt ~= nil then
   local mousex, mousey = love.mouse.getPosition()
   if self.rect:inside(mousex, mousey) then
      self.time_over = self.time_over + dt --Increase time until...
      if self.time_over > self.threshold then self.visible = true end --Tooltip becomes visible
   end
end

Tooltip.event_types = {
   --Heartbeat--
   ["heartbeat"]=function(self, msg) self:popup_timer(msg.dt) end,
   --MOUSE--
   ["mousereleased"]=function(self, msg) self.visible = false; self.time_over = 0 end, --If they let go...become invisible
   ["mouseover_end"]=function(self, msg) self.visible = false; self.time_over = 0 end,
   ["mouseover_cont"]=function(self, msg) self:popup_timer(msg.dt) end,
   --TOUCH--
   ["touchreleased"]=function(self, msg) self.visible = false; self.time_over = 0 end, --If they let go...become invisible
}

function Tooltip:init(new_args)
   --Set the drawable text object
   self.drawable_text = love.graphics.newText(res.fnt[self.font], self.text)
   local width, height = self.drawable_text:getDimensions()
   local x, y = 0, 0
   if type(self._container.rect.x) == "function" then x = self._container.rect.x() else x = self._container.rect.x end
   if type(self._container.rect.x) == "function" then y = self._container.rect.y() else y = self._container.rect.x end
   --Use the same collision rect as your parent object
   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = self._container.rect.width,
      ["height"] = self._container.rect.height,
      ["x"] = self._container.rect.x,
      ["y"] = self._container.rect.y,
      ["z"] = self._container.rect.z + 1,
   }, self)

   self.view = f:new({
      ["component_type"] = "gui.view",
      ["x"] = x - self._container.rect.width/2 + width/2, --Center self on container's rect
      ["y"] = y + self.float_height,
      ["z"] = self.rect.z + 1, --View's z is one higher than container
      ["width"] = width,
      ["height"] = height,
   }, self)
   --d.tprint(self)
   --d.tprint(self.rect)
   return self
end

return Tooltip
