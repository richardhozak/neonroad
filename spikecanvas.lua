local util = require("util")

local width = 50
local miniLength = width / 5
local spike = love.graphics.newCanvas(width, width)
love.graphics.setCanvas(spike)
love.graphics.clear()
love.graphics.setBlendMode("alpha")
util.drawFilledRectangle(miniLength, miniLength, width-miniLength*2, width-miniLength*2, 207, 0, 15)

for i=1,width/miniLength-2 do
    util.drawFilledTriangle(0, i*miniLength, miniLength, "left", 207, 0, 15)
end

for i=1,width/miniLength-2 do
    util.drawFilledTriangle(width-miniLength, i*miniLength, miniLength, "right", 207, 0, 15)
end

for i=1,width/miniLength-2 do
    util.drawFilledTriangle(i*miniLength, 0, miniLength, "top", 207, 0, 15)
end

for i=1,width/miniLength-2 do
    util.drawFilledTriangle(i*miniLength, width-miniLength, miniLength, "bottom", 207, 0, 15)
end

love.graphics.setCanvas()

return spike