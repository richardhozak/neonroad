local util = require("util")
local lume = require("lib.lume")

local Block = require("entity.block")
local Bullet = require("entity.bullet")
local Spike = require("entity.spike")
local SpikeBlock = require("entity.spikeblock")
local Coin = require("entity.coin")
local Wall = require("entity.wall")
local Entity = require("entity.entity")
local Player = Entity:extend()

local speed = 300
local defaultShootTime = 0.2
local acceleration = 200
local decceleration = 100

local thrust = love.audio.newSource("sound/thrust.wav", "static")
thrust:setLooping(true)
thrust:setVolume(0)
thrust:play()

function Player:new(world, camera, x, y, width, height)
    Player.super.new(self, world, x, y, width, height)
    self.camera = camera
    self.horizontal = 0
    self.vertical = 0
    self.shootTime = defaultShootTime
    self.vx = 0
    self.vy = 0
    self.isDead = false
    self.pressedKeys = {}
--     self.particle = self:createParticle()
--     self.particles = love.graphics.newParticleSystem(self.particle, 32)
--     self.particles:setParticleLifetime(0.5, 2) -- Particles live at least 2s and at most 5s.
--     self.particles:setEmissionRate(10)
--     self.particles:setSizeVariation(1)
--     self.particles:setLinearAcceleration(0, 0)
--     self.particles:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
end

function Player:createParticle()
    local particle = love.graphics.newCanvas(20, 20)
    love.graphics.setCanvas(particle)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("fill", 0, 0, 20, 20)
    love.graphics.setCanvas()
    return particle
end

function Player:collisionFilter(other)
    if other:is(Wall) then
        return "slide"
    else
        return "cross"
    end
end

function Player:applyVelocity(dt)
    local vx, vy = self.vx, self.vy

    local horizontalDirection = vx > 0 and 1 or vx < 0 and -1 or 0 --vx == 0 and 0 or vx > 0 and 1 or -1
    local verticalDirection   = vy > 0 and 1 or vy < 0 and -1 or 0

    if self.horizontal ~= 0 then
        local brake = self.horizontal ~= horizontalDirection and horizontalDirection * decceleration or 0
        vx = vx + (dt * self.horizontal * acceleration) - brake * dt
    else
        local horizontalBrake = dt * decceleration * horizontalDirection
        if math.abs(horizontalBrake) > math.abs(vx) then
            vx = 0
        else
            vx = vx - horizontalBrake
        end
    end

    if self.vertical ~= 0 then
        local brake = self.vertical ~= verticalDirection and verticalDirection * decceleration or 0
        vy = vy + (dt * self.vertical * acceleration) - brake * dt
    else
        local verticalBrake = dt * decceleration * verticalDirection
        if math.abs(verticalBrake) > math.abs(vy) then
            vy = 0
        else
            vy = vy - verticalBrake
        end
    end

    return vx, vy
end

function Player:shootOnTime(dt)
    self.shootTime = self.shootTime - dt

    if self.shootTime <= 0 then
        self.shootTime = defaultShootTime

        if self.vertical ~= 0 or self.horizontal ~= 0 then
            local x = self.x + self.horizontal
            local y = self.y + self.vertical
            
            local angle = lume.angle(x, self.y, self.x, y)
            local cx, cy = self:getCenter()
            local bx = cx + math.cos(angle) * self.width
            local by = cy - math.sin(angle) * self.height

            Bullet(self.world, bx, by, -angle)
        end
    end
end

function Player:moveWithVelocity(dt)
    self.vx, self.vy = self:applyVelocity(dt)

    local newX = self.x + self.vx * dt
    local newY = self.y + self.vy * dt

    local x, y, cols, len = self.world:move(self, newX, newY, self.collisionFilter)
    self.x, self.y = x, y

    for i=1, len do
        local col = cols[i].other
        if col:is(Wall) then
            self.vx, self.vy = 0, 0
        elseif col:is(Spike) or col:is(SpikeBlock) then
            self.vx, self.vy = 0, 0
            self.horizontal, self.vertical = 0, 0
            self.isDead = true
            camera:shake(0.1, 3)
        elseif col:is(Coin) then
            col:damage()
        end
    end
end

function Player:update(dt)
    if self.isDead then
        return
    end
    self:moveWithVelocity(dt)
    self:shootOnTime(dt)

    if self.horizontal ~= 0 or self.vertical ~= 0 then
        thrust:setVolume(1)
    else
        thrust:setVolume(0)
    end
end

function Player:draw()
    local x, y = self:getCenter()
    util.drawFilledCircle(x, y, self.width / 2, 38, 166, 91)
end

function Player:keyPressed(key, scancode, isrepeat)
    if self.pressedKeys[scancode] then
        return
    end

    self.pressedKeys[scancode] = true

    if scancode == "up" then
        self.vertical = self.vertical - 1
    end

    if scancode == "down" then
        self.vertical = self.vertical + 1
    end

    if scancode == "left" then
        self.horizontal = self.horizontal - 1
    end

    if scancode == "right" then
        self.horizontal = self.horizontal + 1
    end
end

function Player:keyReleased(key, scancode)
    if not self.pressedKeys[scancode] then
        return
    end

    self.pressedKeys[scancode] = false

    if scancode == "up" then
        self.vertical = self.vertical + 1
    end

    if scancode == "down" then
        self.vertical = self.vertical - 1
    end 

    if scancode == "left" then
        self.horizontal = self.horizontal + 1
    end

    if scancode == "right" then
        self.horizontal = self.horizontal - 1
    end
end

function Player:hit()
    print("hit")
end

return Player