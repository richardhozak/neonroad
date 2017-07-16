local Entity = require("entity.entity")
local util = require("util")
local spike

local SpikeBlock = Entity:extend()
function SpikeBlock:new(world, x, y)
    local width = 50
    local miniLength = width / 5
    self.super.new(self, world, x, y, width, width)
    if not spike then
        spike = require("spikecanvas")
    end
end

function SpikeBlock:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(spike)
    love.graphics.setBlendMode("alpha")
    love.graphics.pop()
end

return SpikeBlock