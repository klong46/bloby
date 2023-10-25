import "CoreLibs/sprites"
import "gameObject"
import "constants"

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
    if self.direction == DIRECTIONS.RIGHT then
        self:moveTo((self.origin.x * TILE_SIZE), (self.origin.y * TILE_SIZE) - 10)
    elseif self.direction == DIRECTIONS.LEFT then
        self:moveTo((self.origin.x * TILE_SIZE) - self.width - 17, (self.origin.y * TILE_SIZE) - 10)
    elseif self.direction == DIRECTIONS.UP then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TILE_SIZE) - 12, (self.origin.y * TILE_SIZE) - (self.height/2) - 15)
    elseif self.direction == DIRECTIONS.DOWN then
        self:setImage(image:rotatedImage(90))
        self:moveTo((self.origin.x * TILE_SIZE) - 12, (self.origin.y * TILE_SIZE) + (self.height/2))
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
    if (self.direction == DIRECTIONS.UP) then
        for i=1,TILES_PER_COLUMN do
            local pos = grid[(self.origin.y-1-i)*TILES_PER_ROW+(self.origin.x)]
            if not (pos == EMPTY_TILE) then
                return i-1
            end
        end
    elseif (self.direction == DIRECTIONS.DOWN) then
        for i=1,TILES_PER_COLUMN do
            local pos = grid[(self.origin.y-1+i)*TILES_PER_ROW+(self.origin.x)]
            if not (pos == EMPTY_TILE) then
                return i-1
            end
        end
    elseif (self.direction == DIRECTIONS.LEFT) then
        for i=1,TILES_PER_ROW do
            local pos = grid[(self.origin.y-1)*TILES_PER_ROW+(self.origin.x-i)]
            if not (pos == EMPTY_TILE) then
                return i-1
            end
        end
    elseif (self.direction == DIRECTIONS.RIGHT) then
        for i=1,TILES_PER_ROW do
            local pos = grid[(self.origin.y-1)*TILES_PER_ROW+(self.origin.x+i)]
            if not (pos == EMPTY_TILE) then
                return i-1
            end
        end
    end
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
