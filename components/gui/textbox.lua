--[[Simple object for storing text to render to screen]]
local Textbox = {}

Textbox.defaults = {
   ["font"] = "default",
   ["align"] = "center", --Valid text alignments include: 'right', 'left' and 'center'
   ["font_size"] = 12,
   ["width"] = 100,
   ["height"] = 100,
   ["x"] = 0,
   ["y"] = 0,
   ["z"] = 1,
   ["text"] = "Hello, World",
   ["padding"] = 0,
   ["text_color"] = {1,0,0,1},
   ["draggable"] = false,
}

function Textbox:draw()
   --Init Things needed for Draw
   love.graphics.setColor(unpack(self.text_color))
   love.graphics.setFont(res.fnt[self.font])
   --Draw Wireframe
   love.graphics.rectangle("line", self.rect.x, self.rect.y, self.width, self.height )
   --Draw Text
   love.graphics.printf(self.text, self.x, self.y, self.width, 'center')
   --Reset Phase
   love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
end

function Textbox:init(new_args)

   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = self.width,
      ["height"] = self.height,
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
      ["resize"] = new_args.resize,
      ["draggable"] = self.draggable,
   }, self)

   self.view = f:new({
      ["component_type"] = "gui.view",
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
   }, self)
end

Textbox.event_types = {
   --MOUSE--
   ["mousepressed"]=function(self, msg) self.rect:receive_msg(msg) end,
   ["mousereleased"]=function(self, msg) self.rect:receive_msg(msg) end,
   ["hover_end"]=function(self, msg) self.rect:receive_msg(msg) end,
   ["hover_cont"]=function(self, msg) self.rect:receive_msg(msg) end,
   --TOUCH--
   ["touchpressed"]=function(self, msg) self.rect:receive_msg(msg) end,
   ["touchreleased"]=function(self, msg) self.rect:receive_msg(msg) end,
   --WINDOW
   ["resize"]=function(self, msg) self.rect:receive_msg(msg) end,
}

return Textbox
