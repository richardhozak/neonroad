local Camera = require("camera")
local Player = require("entity.player")
local bump = require("lib.bump")
local util = require("util")
local lume = require("lib.lume")
local Spike = require("entity.spike")
local SpikeBlock = require("entity.spikeblock")
local Coin = require("entity.coin")
local Block = require("entity.block")
local Bound = require("entity.bound")
local Wall = require("entity.wall")
local Background = require("background")
local bitser = require("lib.bitser")

local world
local player
local coins
local levelIndex
local endObject
local gameOver
local tileSize = 50
local levelCount
local spikeCanvas
local smallFont
local normalFont
local neonFont
local deathCount
local gameTime
local levelTime
local levelTimeTable
local background

function createLevel(world, leveldata)
    local coins = {}
    
    for x, row in pairs(leveldata.items) do
        for y, tile in pairs(row) do
            local realX, realY = x*tileSize, y*tileSize

            if tile == 1 then
            elseif tile == 2 then
                if not player then
                    player = Player(world, camera, realX, realY, tileSize, tileSize)
                end
            elseif tile == 3 then
                SpikeBlock(world, realX, realY, tileSize)
            elseif tile == 4 then
                Spike(world, realX, realY, tileSize, "bottom")
            elseif tile == 5 then
                Spike(world, realX, realY, tileSize, "top")
            elseif tile == 6 then
                Spike(world, realX, realY, tileSize, "left")
            elseif tile == 7 then
                Spike(world, realX, realY, tileSize, "right")
            elseif tile == 8 then
                Block(world, realX, realY, tileSize, tileSize, true)
            elseif tile == 9 then
                table.insert(coins, Coin(world, realX, realY, tileSize))
            elseif tile == 10 then
                Wall(world, realX, realY, tileSize, tileSize)
            end
        end
    end

    return coins
end

function createCameraBounds(world)
    Bound(world, camera, "right")
    Bound(world, camera, "left")
    Bound(world, camera, "top")
    Bound(world, camera, "bottom")
end

function loadLevel(index)
    if index < 0 or index > levelCount then
        return false
    end

    world = bump.newWorld(50)
    player = nil
    local data = bitser.loadLoveFile(string.format("level/%d", index)) --bitser.loadLoveFile("level/level")
    coins = createLevel(world, data)
    camera:setBounds(data.x*tileSize, data.y*tileSize, data.width*tileSize, data.height*tileSize)
    camera:lookAt(player)
    createCameraBounds(world)
    levelTime = 0
    return true
end

function loadNextLevel()
    levelTimeTable[levelIndex] = levelTime
    levelIndex = levelIndex + 1
    return loadLevel(levelIndex)
end

function reloadLevel()
    loadLevel(levelIndex)
end

function love.load()
    love.window.setMode(1000, 750)
    normalFont = love.graphics.newFont("font/PressStart2P.ttf", 16)
    smallFont = love.graphics.newFont("font/PressStart2P.ttf", 12)
    neonFont = love.graphics.newFont("font/Monoton-Regular.ttf", 62)
    spikeCanvas = require("spikecanvas")
    levelCount = #love.filesystem.getDirectoryItems("level")
    camera = Camera()
    background = Background(camera)
    initializeGame()
end

function initializeGame()
    world = nil
    gameOver = false
    levelIndex = 1
    levelTime = 0
    levelTimeTable = {}
    deathCount = 0
end

function love.update(dt)
    background:update(dt)

    if gameOver then
        return
    end

    if world then
        if player.isDead then
            reloadLevel()
            deathCount = deathCount + 1
            return
        end
        
        local items, len = world:getItems()
        for i=1, len do
            items[i]:update(dt)
        end

        camera:update(dt)

        levelTime = levelTime + dt

        if coins then
            if lume.all(coins, function(c) return c.destroyed end) then
                if not loadNextLevel() then
                    gameOver = true
                end
                camera:shake(0, 0)
            end
        end
    end
end

function love.draw()
    if gameOver then
        drawGameOverScreen()
        return
    end

    if world then
        camera:draw(function(x, y, w, h) 
            background:draw()
            --world:debugDraw()
            local items, len = world:getItems()
            for i=1, len do
                items[i]:draw()
            end
        end)

        drawUi()
    else
        drawStartScreen()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if scancode == "escape" then
        love.event.quit()
        return
    end

    if gameOver then
        if scancode == 'r' then
            initializeGame()
        end
        return
    end

    if scancode == "return" then
        reloadLevel()
    end

    if player then
        player:keyPressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if player then
        player:keyReleased(key, scancode)
    end
end

function drawUi()
    local gwidth, gheight = love.graphics.getDimensions()
    local maxWidth = 200
    love.graphics.setFont(normalFont)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(string.format("Deaths: %d", deathCount), gwidth - maxWidth, gheight - normalFont:getHeight(), maxWidth, "right")
    love.graphics.printf(string.format("Level: %d/%d", levelIndex, levelCount), 0, 10, maxWidth, "left")
    love.graphics.printf(string.format("Time: %.2f", levelTime), 0, gheight - normalFont:getHeight(), maxWidth, "left")
end

function drawGameOverScreen()
    love.graphics.setFont(normalFont)
    local gwidth, gheight = love.graphics.getDimensions()
    local textWidth = gwidth * 0.75
    local textXPos = (gwidth - textWidth) / 2

    love.graphics.setColor(255,255,255)
    love.graphics.printf("Congratulations, you completed the game!", textXPos, 100, textWidth, "center")

    if deathCount == 0 then
        love.graphics.printf("You never died.", textXPos, 200, textWidth, "center")
    elseif deathCount == 1 then
        love.graphics.printf("You died only once.", textXPos, 200, textWidth, "center")
    else 
        love.graphics.printf(string.format("You died %d times.", deathCount), textXPos, 200, textWidth, "center")
    end

    local timeYPos = 300
    love.graphics.printf("Your times: ", textXPos, timeYPos, textWidth, "center")
    
    timeYPos = timeYPos + 20

    local completeTime = 0

    for i=1, #levelTimeTable do
        local time = levelTimeTable[i]
        completeTime = completeTime + time
        timeYPos = timeYPos + normalFont:getHeight() + 10
        love.graphics.printf(string.format("Level %d: %.2fs", i, time), gwidth / 2 - 125, timeYPos, textWidth, "left")
    end

    timeYPos = timeYPos + normalFont:getHeight() + 20
    love.graphics.printf(string.format("You completed the whole game in %.2f seconds", completeTime), textXPos, timeYPos + 20, textWidth, "center")

    love.graphics.printf("Thank you for playing!", textXPos, gheight - normalFont:getHeight() - 150, textWidth, "center")

    love.graphics.printf("Restart the game with 'r'.", textXPos, gheight - normalFont:getHeight() - 50, textWidth, "center")
end

local titleText = {{207, 0, 15}, "NEON", {65, 131, 215}, " ROAD"}
function drawStartScreen()
    -- move with arrow keys, when moving you shoot bullets in opposite direction
    -- your objective is to complete each level as fast as possible by collecting all the coins
    -- you can collect coins by running over them or shooting them 4 times
    -- red objects kill you but you can shoot through them
    -- blue objects stop your movement and also stop you bullets
    -- start or restart level with 'enter'

    local gwidth = love.graphics.getWidth()
    local textWidth = gwidth * 0.75
    local textXPos = (gwidth - textWidth) / 2

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(neonFont)
    love.graphics.printf(titleText, textXPos, 25, textWidth, "center")

    love.graphics.setFont(normalFont)

    love.graphics.printf("Move with arrow keys. When moving you also shoot bullets in opposite direction.", textXPos, 150, textWidth, "center")
    love.graphics.printf("Your objective is to complete each level as fast as possible by collecting all the coins.", textXPos, 225, textWidth, "center")
    love.graphics.printf("You can collect coins by running over them or shooting them 4 times.", textXPos, 300, textWidth, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("Bullets are destroyed when out of view.", textXPos, 350, textWidth, "center")
    love.graphics.setFont(normalFont)
    love.graphics.printf("Avoid red blocks!", textXPos/2, 400, textWidth/2, "center")
    local spacing = 50
    local totalWidth = tileSize * 3 + spacing * 2
    local blockX = (gwidth / 2 - totalWidth) / 2
    drawSpike(blockX, 450)
    blockX = blockX + spacing + tileSize
    drawSpikeBlock(blockX, 450)
    blockX = blockX + spacing + tileSize
    drawRedBlock(blockX, 450)
    love.graphics.printf("They will kill you. But you can shoot through them.", textXPos/2, 550, textWidth/2, "center")

    love.graphics.setColor(255,255,255)
    love.graphics.printf("You can touch walls.", gwidth / 2 + textXPos / 2, 400, textWidth/2, "center")
    drawWall(gwidth / 2 + gwidth / 4 - 25,450)
    love.graphics.printf("But they will slow you down and also stop your bullets.", gwidth / 2 + textXPos / 2, 550, textWidth/2, "center")

    love.graphics.setColor(255,255,255)
    love.graphics.printf("Press 'enter' to start or restart the level.", textXPos, 650, textWidth, "center")
end

function drawSpike(x, y)
    local width, height = 50, 50
    local direction = "bottom"
    local halfHeight = height / 2
    util.drawFilledRectangle(x, y, width, halfHeight, 207, 0, 15)
    util.drawFilledTriangle(x, y + halfHeight, halfHeight, direction, 207, 0, 15)
    util.drawFilledTriangle(x + halfHeight, y + halfHeight, halfHeight, direction, 207, 0, 15)
end

function drawSpikeBlock(x, y)
    love.graphics.setColor(255,255,255)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(spikeCanvas)
    love.graphics.setBlendMode("alpha")
    love.graphics.pop()
end

function drawRedBlock(x, y)
    util.drawFilledRectangle(x, y, tileSize, tileSize, 207, 0, 15)
end

function drawWall(x, y)
    util.drawFilledRectangle(x, y, tileSize, tileSize, 65, 131, 215)
end