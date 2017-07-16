local Entity = require("entity.entity")
local util = require("util")

local Spike = Entity:extend()

function Spike:new(world, x, y, width, direction)
    self.super.new(self, world, x, y, width, width)
    self.direction = direction
end

function Spike:update(dt)
end

function Spike:draw()
    if self.direction == "right" then
        local width = self.width / 2
        local height = self.height
        util.drawFilledRectangle(self.x, self.y, width, height, 207, 0, 15)
        util.drawFilledTriangle(self.x + width, self.y, width, self.direction, 207, 0, 15)
        util.drawFilledTriangle(self.x + width, self.y + width, width, self.direction, 207, 0, 15)
    elseif self.direction == "left" then
        local width = self.width / 2
        local height = self.height
        util.drawFilledRectangle(self.x + width, self.y, width, height, 207, 0, 15)
        util.drawFilledTriangle(self.x, self.y, width, self.direction, 207, 0, 15)
        util.drawFilledTriangle(self.x, self.y + width, width, self.direction, 207, 0, 15)
    elseif self.direction == "top" then
        local width = self.width
        local height = self.height / 2
        util.drawFilledRectangle(self.x, self.y + height, width, height, 207, 0, 15)
        util.drawFilledTriangle(self.x, self.y, height, self.direction, 207, 0, 15)
        util.drawFilledTriangle(self.x + height, self.y, height, self.direction, 207, 0, 15)
    elseif self.direction == "bottom" then
        local width = self.width
        local height = self.height / 2
        util.drawFilledRectangle(self.x, self.y, width, height, 207, 0, 15)
        util.drawFilledTriangle(self.x, self.y + height, height, self.direction, 207, 0, 15)
        util.drawFilledTriangle(self.x + height, self.y + height, height, self.direction, 207, 0, 15)
    end
end

return Spike