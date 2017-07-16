local Entity = require("entity.entity")
local Block = Entity:extend()

local util = require("util")

function Block:new(world, x, y, width, height, hurtsPlayer)
    self.hurtsPlayer = hurtsPlayer
    Block.super.new(self, world, x, y, width, height)
end

function Block:draw()
    if self.hurtsPlayer then
        util.drawFilledRectangle(self.x, self.y, self.width, self.height, 207, 0, 15)
    else
        util.drawFilledRectangle(self.x, self.y, self.width, self.height, 31, 58, 147)
    end
end

return Block