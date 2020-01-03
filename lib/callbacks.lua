--[[
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
--]]
------------------------------------------
--[[
Script generated binding of all callbacks in löve. It takes all the callbacks
and wraps them in functions that create frostmoon messages out of them. Then
those event messages are pushed onto the global queue variable "_G.frostmoon.q".
--]]
------------------------------------------

--Callback function triggered when window receives or loses focus.
function love.focus(focus)
    msg = {
        ["type"] = "focus",
        ["args"] = {
            ["focus"] = focus
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when the window is resized
function love.resize(w, h)
    msg = {
        ["type"] = "resize",
        ["args"] = {
            ["w"] = w,
            ["h"] = h
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when window is minimized/hidden or unminimized by the user.
function love.visible(visible)
    msg = {
        ["type"] = "visible",
        ["args"] = {
            ["visible"] = visible
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a file is dragged and dropped onto the window.
function love.filedropped(file)
    msg = {
        ["type"] = "filedropped",
        ["args"] = {
            ["file"] = file
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a directory is dragged and dropped onto the window.
function love.directorydropped(path)
    msg = {
        ["type"] = "directorydropped",
        ["args"] = {
            ["path"] = path
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when window receives or loses mouse focus.
function love.mousefocus(focus)
    msg = {
        ["type"] = "mousefocus",
        ["args"] = {
            ["focus"] = focus
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when the mouse is moved.
function love.mousemoved(x, y, dx, dy, istouch)
    msg = {
        ["type"] = "mousemoved",
        ["args"] = {
            ["x"] = x,
            ["y"] = y,
            ["dx"] = dx,
            ["dy"] = dy,
            ["istouch"] = istouch
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a mouse button is pressed.
function love.mousepressed(x, y, button, istouch, presses)
    msg = {
        ["type"] = "mousepressed",
        ["args"] = {
            ["x"] = x,
            ["y"] = y,
            ["button"] = button,
            ["istouch"] = istouch,
            ["presses"] = presses
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a mouse button is released.
function love.mousereleased(x, y, button, istouch, presses)
    msg = {
        ["type"] = "mousereleased",
        ["args"] = {
            ["x"] = x,
            ["y"] = y,
            ["button"] = button,
            ["istouch"] = istouch,
            ["presses"] = presses
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when the mouse wheel is moved.
function love.wheelmoved(x, y)
    msg = {
        ["type"] = "wheelmoved",
        ["args"] = {
            ["x"] = x,
            ["y"] = y
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a key is pressed.
function love.keypressed(key, scancode, isrepeat)
    msg = {
        ["type"] = "keypressed",
        ["args"] = {
            ["key"] = key,
            ["scancode"] = scancode,
            ["isrepeat"] = isrepeat
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a keyboard key is released.
function love.keyreleased(key, scancode)
    msg = {
        ["type"] = "keyreleased",
        ["args"] = {
            ["key"] = key,
            ["scancode"] = scancode
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when the device display orientation changed.
function love.displayrotated(index, orientation)
    msg = {
        ["type"] = "displayrotated",
        ["args"] = {
            ["index"] = index,
            ["orientation"] = orientation
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a touch press moves inside the touch screen.
function love.touchmoved(id, x, y, dx, dy, pressure)
    msg = {
        ["type"] = "touchmoved",
        ["args"] = {
            ["id"] = id,
            ["x"] = x,
            ["y"] = y,
            ["dx"] = dx,
            ["dy"] = dy,
            ["pressure"] = pressure
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when the touch screen is touched.
function love.touchpressed(id, x, y, dx, dy, pressure)
    msg = {
        ["type"] = "touchpressed",
        ["args"] = {
            ["id"] = id,
            ["x"] = x,
            ["y"] = y,
            ["dx"] = dx,
            ["dy"] = dy,
            ["pressure"] = pressure
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when the touch screen stops being touched.
function love.touchreleased(id, x, y, dx, dy, pressure)
    msg = {
        ["type"] = "touchreleased",
        ["args"] = {
            ["id"] = id,
            ["x"] = x,
            ["y"] = y,
            ["dx"] = dx,
            ["dy"] = dy,
            ["pressure"] = pressure
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when the system is running out of memory on mobile devices.
function love.lowmemory()
    msg = {
        ["type"] = "lowmemory",
        ["args"] = {

        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a Joystick's virtual gamepad axis is moved.
function love.gamepadaxis(joystick, axis, value)
    msg = {
        ["type"] = "gamepadaxis",
        ["args"] = {
            ["joystick"] = joystick,
            ["axis"] = axis,
            ["value"] = value
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a Joystick's virtual gamepad button is pressed.
function love.gamepadpressed(joystick, button)
    msg = {
        ["type"] = "gamepadpressed",
        ["args"] = {
            ["joystick"] = joystick,
            ["button"] = button
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a Joystick's virtual gamepad button is released.
function love.gamepadreleased(joystick, button)
    msg = {
        ["type"] = "gamepadreleased",
        ["args"] = {
            ["joystick"] = joystick,
            ["button"] = button
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a Joystick is connected.
function love.joystickadded(joystick)
    msg = {
        ["type"] = "joystickadded",
        ["args"] = {
            ["joystick"] = joystick
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a Joystick is disconnected.
function love.joystickremoved(joystick)
    msg = {
        ["type"] = "joystickremoved",
        ["args"] = {
            ["joystick"] = joystick
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a joystick axis moves.
function love.joystickaxis(joystick, axis, value)
    msg = {
        ["type"] = "joystickaxis",
        ["args"] = {
            ["joystick"] = joystick,
            ["axis"] = axis,
            ["value"] = value
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a joystick hat direction changes.
function love.joystickhat(joystick, hat, direction)
    msg = {
        ["type"] = "joystickhat",
        ["args"] = {
            ["joystick"] = joystick,
            ["hat"] = hat,
            ["direction"] = direction
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a joystick button is pressed.
function love.joystickpressed(joystick, button)
    msg = {
        ["type"] = "joystickpressed",
        ["args"] = {
            ["joystick"] = joystick,
            ["button"] = button
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when a joystick button is released.
function love.joystickreleased(joystick, button)
    msg = {
        ["type"] = "joystickreleased",
        ["args"] = {
            ["joystick"] = joystick,
            ["button"] = button
        }
    }
    _G.frostmoon.q:add(msg)
end

--Callback function triggered when a Thread encounters an error.
function love.threaderror(thread, errorstr)
    msg = {
        ["type"] = "threaderror",
        ["args"] = {
            ["thread"] = thread,
            ["errorstr"] = errorstr
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when the candidate text for an IME (Input Method Editor) has changed.
function love.textedited(text, start, length)
    msg = {
        ["type"] = "textedited",
        ["args"] = {
            ["text"] = text,
            ["start"] = start,
            ["length"] = length
        }
    }
    _G.frostmoon.q:add(msg)
end

--Called when text has been entered by the user.
function love.textinput(text)
    msg = {
        ["type"] = "textinput",
        ["args"] = {
            ["text"] = text
        }
    }
    _G.frostmoon.q:add(msg)
end
