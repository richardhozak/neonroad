local Entity = require("entity.entity")
local util = require("util")
local Coin = Entity:extend()

function Coin:new(world, x, y, size)
    self.points = 4
    self.super.new(self, world, x, y, size, size)
    self.destroySound  = love.audio.newSource("sound/coin.wav", "static")
    self.destroySound:setVolume(1.5)
end

function Coin:update(dt)
end

function Coin:damage()
    if self.destroyed then
        return
    end

    self.points = self.points - 1
    if self.points <= 1 then
        self:destroy()
        self.destroySound:play()
    end
end

function Coin:draw()
    local cx, cy = self:getCenter()
    util.drawFilledCircle(cx, cy, (self.width / 2) * (self.points / 4), 249, 191, 59)
end

return Coin