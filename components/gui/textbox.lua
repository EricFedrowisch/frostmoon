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
   ["text_color"] = {1,0,0,1}
}

function Textbox:draw()
   love.graphics.setColor(unpack(self.text_color))
   love.graphics.setFont(res.fnt[self.font])

   local x, y = 0, 0
   if type(self.x) == "function" then x = self.x() else x = self.x  end
   if type(self.y) == "function" then y = self.y() else y = self.y  end

   love.graphics.rectangle("line", x, y, self.width, self.height )
   --love.graphics.printf( text, x, y, limit, align )
   love.graphics.printf(self.text, x, y, self.width, 'center')
   love.graphics.setColor(1,1,1,1) --Reset Color to White to Prevent messing up other stuff
end

function Textbox:init(new_args)
   --[[
   if new_args.font_size ~= 12 then --Fonts are size 12 by default, set new font if different
      local font = new_args.font or "default" --Either given font name or 'default'
      if font == "default" then
         self.font_obj = love.graphics.newFont(12)
      else
         self.font_obj = love.graphics.newFont(res.fnt_files[new_args.font], new_args.font_size)
      end
   else
      self.font_obj = res.fnt[new_args.font]
   end
   ]]

   self.rect = f:new({
      ["component_type"] = "gui.rect",
      ["width"] = self.width,
      ["height"] = self.height,
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
   }, self)

   self.view = f:new({
      ["component_type"] = "gui.view",
      ["x"] = self.x,
      ["y"] = self.y,
      ["z"] = self.z,
   }, self)
   return self
end


return Textbox
