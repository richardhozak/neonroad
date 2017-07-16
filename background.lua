local lume = require("lib.lume")
local Object = require("lib.classic")

local Background = Object:extend()

function Background:new(camera)
    self.camera = camera
    self.x, self.y = 0, 0    
    self.width, self.height = camera.width, camera.height
    self.currentTime = 0.0
    self.spawnTime = 0.25
    self.lines = {}
end

function Background:update(dt)
    self.x = self.camera.bounds.x
    self.y = self.camera.bounds.y
    self.width = self.camera.bounds.width
    self.height = self.camera.bounds.height

    self.currentTime = self.currentTime + dt
    if self.currentTime >= self.spawnTime then
        self.currentTime = 0
        table.insert(self.lines, self:createRandomLine())
    end

    for k, v in lume.ripairs(self.lines) do
        if v.x then
            v.x = v.x + v.xSpeed * dt
            v.y = v.y + v.ySpeed * dt
            v.time = v.time + dt

            if v.time > 10 then
                self.lines[k] = nil
            end
        end
    end
end

function Background:isOutOfBounds(line)
    return line.y + line.height > self.y + self.height
end

function Background:createRandomLine()
    local line = {}       

    line.x = lume.random(self.x, self.x + self.width)
    line.y = self.y
    line.xSpeed = 0
    line.ySpeed = lume.random(200, 600)
    line.width = 0
    line.height = lume.random(200, 400)
    line.time = 0

    return line
end

function Background:draw()
    love.graphics.setColor(102,51,153, 75)
    love.graphics.setLineWidth(1)
    --love.graphics.rectangle("fill", 0, 0, 200, 200)
    for k, v in lume.ripairs(self.lines) do
        love.graphics.line(v.x, v.y, v.x - v.width, v.y - v.height)
    end
end

return Background