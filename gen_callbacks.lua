local args = {...} --Get arguments passed when this module is loaded
local q = args[1] --The main Queue object from main.lua
local love = args[2] --The main Löve table from main.lua

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
q:add(msg)
end

function love.keypressed(key, scancode, isrepeat) 
msg = {
    ["type"] = "keypressed",
    ["args"] = {
        ["key"] = key,
        ["scancode"] = scancode,
        ["isrepeat"] = isrepeat
    }
}
q:add(msg)
end

function love.keyreleased(key, scancode) 
msg = {
    ["type"] = "keyreleased",
    ["args"] = {
        ["key"] = key,
        ["scancode"] = scancode
    }
}
q:add(msg)
end

