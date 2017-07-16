local util = require("util")

local Entity = require("entity.entity")

local Bound = Entity:extend()
function Bound:new(world, camera, side)
    self.side = side
    self.camera = camera
    local width = 50
    local height = 100
    self.super.new(self, world, 0, 0, width, height)
end

function Bound:update(dt)
    local cameraHeight = self.camera.height
    local cameraWidth = self.camera.width

    cameraHeight = cameraHeight > 0 and cameraHeight or 1
    cameraWidth = cameraWidth > 0 and cameraWidth or 1

    if self.side == "left" then
        self.width, self.height = 20, cameraHeight
        self.x, self.y = self.camera.x - self.width, self.camera.y
    elseif self.side == "right" then
        self.width, self.height = 20, cameraHeight
        self.x, self.y = self.camera.x + cameraWidth, self.camera.y
    elseif self.side == "top" then
        self.width, self.height = cameraWidth, 20
        self.x, self.y = self.camera.x, self.camera.y - self.height
    elseif self.side == "bottom" then
        self.width, self.height = cameraWidth, 20
        self.x, self.y = self.camera.x, self.camera.y + cameraHeight
    end
    
    self.world:update(self, self.x, self.y, self.width, self.height)
end

function Bound:draw()
    -- util.drawFilledRectangle(self.x, self.y, self.width, self.height, 255, 255, 255)
end

return Bound