local util = require("util")
local Entity = require("entity.entity")
local Spike = require("entity.spike")
local Coin = require("entity.coin")
local Bound = require("entity.bound")
local Wall = require("entity.wall")

local Bullet = Entity:extend()


local defaultTimeToLive = 1
local speed = 1000

function Bullet:new(world, x, y, rotation)
    local width, height = 20,20
    x = (x - width / 2)
    y = (y - height / 2)
    self.rotation = rotation
    self.super.new(self, world, x, y, width, height)
    self.timeToLive = defaultTimeToLive
    self.shootSound = love.audio.newSource("sound/shoot.wav", "static")
    self.shootSound:setVolume(0.2)
    self.shootSound:play()
    self.hitSound = love.audio.newSource("sound/hit.wav", "static")
    self.hitSound:setVolume(0.3)
end

function Bullet:collisionFilter(other)
    return "cross"
end

function Bullet:update(dt)
    if self.destroyed then 
        return
    end

    self.timeToLive = self.timeToLive - dt
    if self.timeToLive > 0 then
        local newX = self.x + math.cos(self.rotation) * speed * dt
        local newY = self.y + math.sin(self.rotation) * speed * dt
        local cols, len = nil, nil
        self.x, self.y, cols, len = self.world:move(self, newX, newY, self.collisionFilter)

        for i=1, len do
            if self.destroyed then
                return
            end

            local col = cols[i]
            if col.other:is(Coin) then
                col.other:damage()
                self:destroy()
                camera:shake(0.075, 1)
                self.hitSound:play()
            elseif col.other:is(Wall) then
                self.hitSound:play()
                self:destroy()
            elseif col.other:is(Bound) then
                self:destroy()
            end
        end
    else
        self:destroy()
    end
end

function Bullet:draw()
    local cx, cy = self:getCenter()
    util.drawFilledCircle(cx, cy, self.width / 2, 65, 131, 215)
end

return Bullet