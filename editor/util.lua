local util = {}

util.drawFilledRectangle = function(l,t,w,h, r,g,b)
  love.graphics.setColor(r,g,b,100)
  love.graphics.rectangle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle('line', l,t,w,h)
  -- love.graphics.setColor(255, 255, 255)
  -- love.graphics.print(l/w .. ", " .. t/h, l, t)
end

util.drawFilledCircle = function(x, y, radius, r, g, b)
    love.graphics.setColor(r, g, b, 100)
    love.graphics.circle("fill", x, y, radius)
    love.graphics.setColor(r, g, b, 255)
    love.graphics.circle("line", x, y, radius)
end

local sqrt3 = math.sqrt(3)
local triangleConst = sqrt3/2
local base = 20
local length = (base*triangleConst)

util.drawFilledTriangle = function(x, y, base, direction, r, g, b)
    local halfBase = base / 2
    if direction == "bottom" then
        love.graphics.setColor(r,g,b,100)
        love.graphics.polygon("fill", x, y, x+base, y, x+halfBase, y+base)
        love.graphics.setColor(r,g,b,255)
        love.graphics.polygon("line", x, y, x+base, y, x+halfBase, y+base)
    elseif direction == "right" then
        love.graphics.setColor(r,g,b,100)
        love.graphics.polygon("fill", x, y, x+base, y+halfBase, x, y+base)
        love.graphics.setColor(r,g,b,255)
        love.graphics.polygon("line", x, y, x+base, y+halfBase, x, y+base)
    elseif direction == "top" then
        love.graphics.setColor(r,g,b,100)
        love.graphics.polygon("fill", x+halfBase, y, x+base, y+base, x, y+base)
        love.graphics.setColor(r,g,b,255)
        love.graphics.polygon("line", x+halfBase, y, x+base, y+base, x, y+base)
    elseif direction == "left" then
        love.graphics.setColor(r,g,b,100)
        love.graphics.polygon("fill", x, y+halfBase, x+base, y, x+base, y+base)
        love.graphics.setColor(r,g,b,255)
        love.graphics.polygon("line", x, y+halfBase, x+base, y, x+base, y+base)
    end
end

function util.clone(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

return util
