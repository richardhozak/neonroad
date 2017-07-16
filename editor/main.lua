local Editor = require("editor")
local Camera = require("camera")

local editor
local camera

function love.load(args)
    if #args ~= 2 then
        print("need to specify level as argument")
        love.event.quit()
        return
    end

    local levelName = args[2]
    love.window.setMode(1280, 1024)
    love.window.setTitle(levelName)

    camera = Camera()
    editor = Editor(camera)
    editor:load(levelName)
    editor:reset()
end

function love.update(dt)
    editor:update(dt)
    camera:update(dt)
end

function love.draw()
    camera:draw(function(x, y, w, h)
        editor:draw(x, y, w, h)
    end)
end

function love.keypressed(key, scancode, isrepeat)
    editor:keyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    editor:keyReleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch)
    editor:mousePressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    editor:mouseReleased(x, y, button, istouch)
end

function love.mousemoved(x, y, dx, dy, istouch)
    editor:mouseMoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
    editor:wheelMoved(x, y)
end