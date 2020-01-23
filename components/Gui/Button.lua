--[[Simple Button class here.]]
local Button = {}

Button.defaults = {
   button_function = function(self, msg) print("DEFAULT BUTTON FUNCTION INVOKED") end, --What to do when pressed
   psp_x = 1/8, --Positive space proportion on x axis
   psp_y = 1/8, --Positive space proportion on y axis
   x = 0,
   y = 0,
   z = 1,
   --toggleable = false,
   --draggable  = false,
   --interact_sound = nil,
   --tooltip = 'Default tooltip',
}

-- function Button:enter_released() self.button_function() end
-- function Button:exit_released() self.fsm:get_input('return_to_idle') end
-- function Button:enter_hover_over() if self.tooltip ~= nil then self.tooltip_count = 0 end end
-- function Button:exit_hover_over() if self.tooltip ~= nil then self.tooltip_count = 0 end end
-- function Button:while_hover_over()
--    if self.tooltip ~= nil then
--       self.tooltip_count = self.tooltip_count + 1
--       if self.tooltip_count >= 30 then self.draw_tooltip = true end
--    end
-- end
-- function Button:exit_pressed() self.fsm:get_input('return_to_idle') end

function Button:init(args)
   local image = self.image or res.img["No-Image.png"] --Initialize image or use default
   local image_on_interact = self.interact_image or image --Initialize interact image or use default
   self.image_initial, self.interact_image_initial = image, image_on_interact --Set initial images to the original sized image
   self.image = _G.res.resize(image, self.psp_x, self.psp_y, self.maintain_aspect_ratio) --Resize image
   self.interact_image = _G.res.resize(image_on_interact, self.psp_x, self.psp_y, self.maintain_aspect_ratio)  --Resize interact image

   self.element = Element{
      __container = self,
      image = self.image,
      x = self.x,
      y = self.y,
      z = self.z,
      psp_x = self.psp_x, --Positive space proportion on x axis
      psp_y = self.psp_x, --Positive space proportion on y axis
   }

   --Use element's rect
   self.rect = self.element.rect
   --Use a FSM to store the state of the button
   self.fsm = FSM{__container = self}

   -- enter_pressed, exit_pressed, while_pressed
   --FSM:register_state(name, enter, exit, during)
   self.fsm:register_state('Idle')
   self.fsm:register_state('Released', 'button_function')
   self.fsm:register_state('Hovered_on')
   self.fsm:register_state('Pressed')

   --FSM:register_transition(input, start_state, end_state)
   --self.fsm:register_transition('Idle' , 'Hovered_on') --Hover over
   --self.fsm:register_transition('Hovered_on' , 'Hovered_on') --Hover over
   self.fsm:register_transition('Hovered_on', 'Pressed') --Button pressed
   self.fsm:register_transition('Idle', 'Pressed')
   self.fsm:register_transition('Idle', 'Released')
   self.fsm:register_transition('Pressed', 'Released') --Button press released
   self.fsm:register_transition('Released', 'Idle') --Return to idle from released
   --self.fsm:register_transition('Hovered_on', 'Idle') --End hover
   --self.fsm:register_transition('Pressed', 'Idle') --End hover
   --Enable fsm
   self.fsm:enable("Idle")
end



Button.event_types = {
   mousepressed = function(self, msg) self.fsm:get_input('Pressed') end,
   touchpressed = function(self, msg) self.fsm:get_input('Pressed') end,
   mousereleased = function(self, msg) self.fsm:get_input('Released') end,
   touchreleased = function(self, msg) self.fsm:get_input('Released') end,
   --hover_end = function(self, msg) self.fsm:get_input('Idle') end,
   --hover_cont = function(self, msg) self.fsm:get_input('Hovered_on') end,
   --resize = function(self, msg) self.fsm:get_input('msg', msg.args) end
}

return Button
