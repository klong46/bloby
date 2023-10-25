import "CoreLibs/sprites"
import "gameObject"

local PD <const> = playdate
local GFX <const> = PD.graphics

class('Laser').extends(GameObject)

local imagePath = 'img/laser/laser_'

function Laser:init(position, grid, direction)
    Laser.super.init(self)
    self.origin = position
    self.direction = direction
    self.length = self:setLength(grid)
    local image = GFX.image.new(imagePath..self.length)
    self:setImage(image)
    self:setCenter(0, 0.5)
    if self.direction == 'right' then
        self:moveTo((self.origin.x * TileSize), (self.origin.y * TileSize) - 10)
    elseif self.direction == 'left' then
        self:moveTo((self.origin.x * TileSize) - self.width - 17, (self.origin.y * TileSize) - 10)
    elseif self.direction == 'up' then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TileSize) - 12, (self.origin.y * TileSize) - (self.height/2) - 15)
    elseif self.direction == 'down' then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TileSize) - 12, (self.origin.y * TileSize) + (self.height/2))
    end
    self:add()
end

function Laser:setVisible(turn)
    if (turn+1) % 2 == 0 then
        self:remove()
    else
        self:add()
    end
end

function Laser:isVisible(turn)
    if (turn+1) % 2 == 0 then
        return false
    end
    return true
end

function Laser:setLength(grid)
    if (self.direction == 'up') then
        for i=1,TilesPerColumn do
            local pos = grid[(self.origin.y-1-i)*TilesPerRow+(self.origin.x)]
            if not (pos == 0) then
                return i-1
            end
        end
    elseif (self.direction == 'down') then
        for i=1,TilesPerColumn do
            local pos = grid[(self.origin.y-1+i)*TilesPerRow+(self.origin.x)]
            if not (pos == 0) then
                return i-1
            end
        end
    elseif (self.direction == 'left') then
        for i=1,TilesPerRow do
            local pos = grid[(self.origin.y-1)*TilesPerRow+(self.origin.x-i)]
            if not (pos == 0) then
                return i-1
            end
        end
    elseif (self.direction == 'right') then
        for i=1,TilesPerRow do
            local pos = grid[(self.origin.y-1)*TilesPerRow+(self.origin.x+i)]
            if not (pos == 0) then
                return i-1
            end
        end
    end
end

function Laser:getTilePositions()
    local tiles = {}
    local xStepDirection = 1
    if self.direction == 'left' then
        xStepDirection = -1
    end
    for i = 1, self.length, 1 do
        table.insert( tiles, PD.geometry.point.new(self.origin.x + (i * xStepDirection), self.origin.y) )
    end
    return tiles
end
