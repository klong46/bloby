import "CoreLibs/sprites"
import "gameObject"
import "constants"

class('Laser').extends(GameObject)

local imagePath = 'img/laser/laser_'

local HORIZONTAL_Y_OFFSET = 10
local HORIZONTAL_X_OFFSET = 17
local VERTICAL_X_OFFSET = 12
local VERTICAL_Y_OFFSET = 15


function Laser:init(position, grid, direction, cadence, offset)
    Laser.super.init(self)
    self.origin = position
    self.direction = direction
    self.cadence = cadence
    self.offset = offset
    self.length = self:setLength(grid)
    local image = self:getImage()
    self:setImage(image)
    self:setInitialPosition(image)
    self:setCenter(0, 0.5)
    self:add()
end

function Laser:getImage()
    if self.length < 1 then
        return GFX.image.new(1)
    end
    return GFX.image.new(imagePath..self.length)
end

function Laser:setInitialPosition(image)
    if self.direction == DIRECTIONS.RIGHT then
        self:moveTo((self.origin.x * TILE_SIZE), (self.origin.y * TILE_SIZE) - HORIZONTAL_Y_OFFSET)
    elseif self.direction == DIRECTIONS.LEFT then
        self:moveTo((self.origin.x * TILE_SIZE) - self.width - HORIZONTAL_X_OFFSET, (self.origin.y * TILE_SIZE) - HORIZONTAL_Y_OFFSET)
    elseif self.direction == DIRECTIONS.UP then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TILE_SIZE) - VERTICAL_X_OFFSET, (self.origin.y * TILE_SIZE) - (self.height/2) - VERTICAL_Y_OFFSET)
    elseif self.direction == DIRECTIONS.DOWN then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TILE_SIZE) - VERTICAL_X_OFFSET, (self.origin.y * TILE_SIZE) + (self.height/2))
    end
end

function Laser:setVisible(turn)
    if not self:isVisible(turn) then
        self:remove()
    else
        self:add()
    end
end

function Laser:isVisible(turn)
    return not ((turn + self.offset) % self.cadence == 0)
end

local function laserBlocked(position)
    return (position ~= EMPTY_TILE) and (position ~= PLAYER_TILE)
end

local function getTile(x, y, grid)
    return grid[(y-1) * TILES_PER_ROW + x]
end

local function getLaserPositionValue(direction, origin, i, grid)
    if (direction == DIRECTIONS.UP) then
        return getTile(origin.x, origin.y-i, grid)
    elseif (direction == DIRECTIONS.DOWN) then
        return getTile(origin.x, origin.y+i, grid)
    elseif (direction == DIRECTIONS.LEFT) then
        return getTile(origin.x-i, origin.y, grid)
    elseif (direction == DIRECTIONS.RIGHT) then
        return getTile(origin.x+i, origin.y, grid)
    end
end

function Laser:setLength(grid)
    local maxLength
    if self.direction == DIRECTIONS.UP or self.direction == DIRECTIONS.DOWN then
        maxLength = TILES_PER_COLUMN-1
    else
        maxLength = TILES_PER_ROW-1
    end
    for i=1,maxLength do
        local position = getLaserPositionValue(self.direction, self.origin, i, grid)
        if laserBlocked(position) then
            return i-1
        end
    end
    return maxLength -- if laser if full length of screen (no obstacles)
end

function Laser:getTilePositions()
    local tiles = {}
    local stepDirection = 1
    if self.direction == DIRECTIONS.LEFT or self.direction == DIRECTIONS.UP then
        stepDirection = -1
    end
    if self.direction == DIRECTIONS.LEFT or self.direction == DIRECTIONS.RIGHT then
        for i = 1, self.length do
            table.insert(tiles, PD.geometry.point.new(self.origin.x + (i * stepDirection), self.origin.y))
        end
    elseif self.direction == DIRECTIONS.UP or self.direction == DIRECTIONS.DOWN then
        for i = 1, self.length do
            table.insert(tiles, PD.geometry.point.new(self.origin.x, self.origin.y + (i * stepDirection)))
        end
    end
    return tiles
end
