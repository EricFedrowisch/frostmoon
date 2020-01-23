--[[Simple object for storing text to render to screen]]
local Textbox = {}

Textbox.defaults = {
   font = 'default',
   text_align = 'center', --Valid text alignments include: 'right', 'left' and 'center'
   align = 'center', --Valid px,py alignments include: 'absolute' and 'center'
   font_size = 12,
   width = 100,
   height = 50,
   x = 0,
   y = 0,
   z = 1,
   text = 'Hello, World',
   padding = 0,
   text_color = {0,0,0,1},
   background_color = {1,1,1,1},
   border_color = {1,0,0,1},
   draggable = false,
}

function Textbox:mk_img()
   local cnvs = love.graphics.newCanvas(self.width, self.height) --Create temp canvas
   love.graphics.setCanvas(cnvs) --Make temp canvas current draw target
   love.graphics.clear(unpack(self.background_color)) --Clear to background color
   --Draw Border rectangle
   love.graphics.setColor(unpack(self.border_color))
   love.graphics.rectangle('line', 0, 0, self.width, self.height)
   --Draw Text
   love.graphics.setColor(unpack(self.text_color))
   love.graphics.setFont(res.fnt[self.font])
   love.graphics.printf(self.text, 0, 0, self.width, self.text_align)
   --Reset Phase
   love.graphics.setCanvas() --Important! Reset draw target to main screen.
   local img = love.graphics.newImage(cnvs:newImageData()) --Make new image from canvas ImageData
   cnvs = nil --Delete temp canvas reference so it can be garbage collected
   love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
   return img
end

function Textbox:init(args)
   local screen_width, screen_height = love.window.getMode()
   if self.px ~= nil then self.x = self.px * screen_width end --If px supplied use it to find x
   if self.py ~= nil then self.y = self.py * screen_height end --If py supplied use it to find y
   local img = self:mk_img()
   self.element = Element{
      __container = self,
      image = img,
      psp_x = self.psp_x,
      psp_y = self.psp_y,
      x = self.x,
      y = self.y,
      z = self.z,
   }
   self.rect = self.element.rect
   if self.align == 'center' then self.rect:center_on_xy(self.x, self.y) end
end

Textbox.event_types = {
   -- --MOUSE--
   -- mousepressed = function(self, msg) self.rect:receive_msg(msg) end,
   -- mousereleased = function(self, msg) self.rect:receive_msg(msg) end,
   -- hover_end = function(self, msg) self.rect:receive_msg(msg) end,
   -- hover_cont = function(self, msg) self.rect:receive_msg(msg) end,
   -- --TOUCH--
   -- touchpressed = function(self, msg) self.rect:receive_msg(msg) end,
   -- touchreleased = function(self, msg) self.rect:receive_msg(msg) end,
   -- --WINDOW
   -- resize = function(self, msg) self.rect:receive_msg(msg) end,
}

return Textbox
