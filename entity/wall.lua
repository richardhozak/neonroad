local Entity = require("entity.entity")
local util = require("util")

local Wall = Entity:extend()

function Wall:new(world, x, y, width, height)
    self.super.new(self, world, x, y, width, height)
end

function Wall:draw()
    -- util.drawFilledRectangle(self.x, self.y, self.width, self.height, 51, 110, 123)
    util.drawFilledRectangle(self.x, self.y, self.width, self.height, 65, 131, 215)
end

return Wall