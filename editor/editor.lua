local util = require("util")
local lume = require("lume")
local bitser = require("bitser")

local Object = require("classic")
local Editor = Object:extend()

local tiles = {
    {name="blank", color={228,241,254}},  --1
    {name="player", color={103,128,159}}, --2
    {name="sblock", color={25,181,254}},  --3
    {name="sdown", color={192,52,43}},    --4
    {name="sup", color={255,10,75}},     --5
    {name="sleft", color={38,194,129}},   --6
    {name="sright", color={155,89,182}},  --7
    {name="block", color={123,123,182}},  --8
    {name="coin", color={249, 191, 59}},  --9
    {name="wall", color={99, 125, 45}},   --10
}

function Editor:new(camera)
    self.normalFont = love.graphics.newFont(12)
    self.boldFont = love.graphics.newFont(30)
    love.graphics.setFont(self.normalFont)
    self.camera = camera
end

function Editor:reset()
    if not map then
        print("editor map not set")
    end

    self.tileSize = 32
    self.selectedTileIndex = 1
    self.font = love.graphics.newFont(13)
    self.camera:setBounds()
    self.camera:setPosition(self.map.x * self.tileSize, self.map.y * self.tileSize)
    self.camera:lookAt(nil)
    self.mouseLeftPressed = false
    self.mouseRightPressed = false
    self.tileName = ""
end

function Editor:getDefaultMap()
    return {
        x=0,
        y=0,
        width=0,
        height=0,
        items={},
    }
end

function Editor:paintTile(index, x, y)
    local mapItems = self.map.items
        
    if not index then
        if mapItems[x] then
            mapItems[x][y] = nil

            if lume.count(mapItems[x]) == 0 then
                mapItems[x] = nil
            end
        end
        return
    end

    if mapItems[x] == nil then
        mapItems[x] = {}
    end

    mapItems[x][y] = index ~= 1 and index or nil
end

function Editor:update(dt)
    self.tileName = tiles[self.selectedTileIndex].name
end

function Editor:draw(x, y, w, h)
    self:drawCheckerBoard(x,y,w,h)
    self:drawMapBorder()
    self:drawMap()
    love.graphics.setFont(self.boldFont)
    love.graphics.print(self.tileName, x, y + h - self.boldFont:getHeight())
    love.graphics.setFont(self.normalFont)
end

function Editor:drawMapBorder()
    local map = self.map
    local x,y = map.x * self.tileSize, map.y*self.tileSize
    local w,h = map.width*self.tileSize, map.height*self.tileSize
    love.graphics.setColor(255,255,255,20)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(255,255,255,50)
    love.graphics.rectangle("line", x, y, w, h)
end

function Editor:drawCheckerBoard(x, y, w, h)
    local beginX = math.floor(x / self.tileSize) * self.tileSize
    local beginY = math.floor(y / self.tileSize) * self.tileSize
    local horizontalCount = math.ceil(w / self.tileSize) + 1
    local verticalCount = math.ceil(h / self.tileSize) + 1
    local xEven = math.floor(x / self.tileSize) % 2 == 0
    local yEven = math.floor(y / self.tileSize) % 2 == 0
    local evenOffset = (xEven and 1 or 0) + (yEven and 1 or 0)

    love.graphics.push()
    love.graphics.translate(beginX, beginY)
    for i=1, horizontalCount do
        for j=1, verticalCount do
            local x = (i-1)*self.tileSize
            local y = (j-1)*self.tileSize
            local isEven = ((i + j + evenOffset) % 2 == 0)
            local color = isEven and {52,52,52} or {65,65,65}
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
        end
    end
    love.graphics.pop()
end

function Editor:drawMap()
    for x, row in pairs(self.map.items) do
        for y, index in pairs(row) do
            local tile = tiles[index]
            love.graphics.setColor(tile.color)
            local realX, realY = x*self.tileSize, y*self.tileSize
            love.graphics.rectangle("fill", realX, realY, self.tileSize, self.tileSize)
            love.graphics.setColor(255,255,255)
            love.graphics.print(tile.name, realX, realY)
        end
    end
end

function Editor:getSelectedPosition(items, comparer)
    local selectedX, selectedY = nil, nil

    for x, row in pairs(items) do
        if not selectedX then
            selectedX = x
        else
            if comparer(selectedX, x) then
                selectedX = x
            end
        end

        for y, index in pairs(row) do
            if not selectedY then
                selectedY = y
            else
                if comparer(selectedY, y) then
                    selectedY = y
                end
            end
        end
    end

    return selectedX, selectedY
end

function Editor:getSmallestPosition(items)
    return self:getSelectedPosition(items, function(selected, current) return current < selected end)
end

function Editor:getLargestPosition(items)
    return self:getSelectedPosition(items, function(selected, current) return current > selected end)
end

function Editor:toMapCoordinates(worldX, worldY)
    return math.floor(worldX / self.tileSize), math.floor(worldY / self.tileSize)
end

function Editor:load(filename)
    print("loading editor map", filename)
    local filepath = filename
    
    self.loadedMapName = filename
    if love.filesystem.exists(filepath) then
        self.map = bitser.loadLoveFile(filepath)
    else
        self.map = self:getDefaultMap()
        self:save()
    end

    self:reset()
end

function Editor:save(filename)
    if not filename then
        if self.loadedMapName then
            filename = self.loadedMapName
        else
            error("could not save map (map not loaded or filename not passed)")
        end
    end

    local smallestX, smallestY = self:getSmallestPosition(self.map.items)
    local largestX, largestY = self:getLargestPosition(self.map.items)

    self.map.x = smallestX or 0
    self.map.y = smallestY or 0
    self.map.width = (largestX or 0) - self.map.x + (largestX and 1 or 0)
    self.map.height = (largestY or 0) - self.map.y + (largestY and 1 or 0)

    print("sx",smallestX, "sy", smallestY, "lx", largestX, "ly", largestY, "map", self.map.width, self.map.height)

    bitser.dumpLoveFile(filename, self.map)
end

function Editor:mousePressed(x, y, button)
    if button == 1 then
        self.mouseLeftPressed = true
        local worldX, worldY = self.camera:toWorld(x, y)
        local tileX, tileY = self:toMapCoordinates(worldX, worldY)
        local index = self.selectedTileIndex 
        self:paintTile(index ~= 1 and index or nil, tileX, tileY)
    elseif button == 2 then
        self.mouseRightPressed = true
    end
end

function Editor:mouseReleased(x, y, button)
    if button == 1 then
        self.mouseLeftPressed = false
    elseif button == 2 then
        self.mouseRightPressed = false
    end
end

function Editor:wheelMoved(x, y)
    if love.keyboard.isDown("lctrl") then
        self.camera.scale = lume.clamp(self.camera.scale - y, 1, 5)
    else
        self.selectedTileIndex = lume.clamp(self.selectedTileIndex - y, 1, #tiles)
    end
end

function Editor:mouseMoved(x, y, dx, dy, istouch)
    if self.mouseLeftPressed then
        local worldX, worldY = self.camera:toWorld(x, y)
        local tileX, tileY = self:toMapCoordinates(worldX, worldY)
        local index = self.selectedTileIndex 
        self:paintTile(index ~= 1 and index or nil, tileX, tileY)
    elseif self.mouseRightPressed then
        self.camera:move(-dx, -dy)
    end
end

function Editor:keyPressed(key, scancode)
    local num = tonumber(scancode)

    if love.keyboard.isDown("lctrl") and key == "s" then
        self:save(self.mapname)
    end

    if love.keyboard.isDown("lctrl") and key == "n" then
        self:normalizeMap()
    end

    if num and num >= 1 and num <= #tiles then
        self.selectedTileIndex = num
    end
end

function Editor:keyReleased(key, scancode)
end

return Editor