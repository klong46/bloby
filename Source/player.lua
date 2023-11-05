import "CoreLibs/sprites"
import "gameObject"
import "constants"

local PLAYER_IMAGES <const> = {
    up = GFX.image.new('img/player/player_up'),
    down = GFX.image.new('img/player/player_down'),
    left = GFX.image.new('img/player/player_left'),
    right = GFX.image.new('img/player/player_right')
}

local lastDirection

class('Player').extends(GameObject)

function Player:init(position, direction)
    local image = PLAYER_IMAGES.down
    Player.super.init(self, image)
    self.position = position
    self.direction = direction
    self.pastMoves = {}
    self.isBlocked = false
    self:setDirection(direction)
    lastDirection = direction
    self.canTurn = false
    self:setZIndex(1)
    self:setPosition()
    self:add()
end

local function getTile(x, y)
    return ((y-1)*TILES_PER_ROW)+x
end

function Player:addPastMove()
    local newPos = PD.geometry.point.new(self.position.x, self.position.y)
    local newDir = self.direction
    local isBlocked = false
    if newDir ~= lastDirection then
        isBlocked = true
        lastDirection = newDir
    end
    -- allows player to turn if reversed to a tile they turned at previously
    table.insert(self.pastMoves, {position = newPos, direction = newDir, isBlocked = isBlocked})
end

function Player:moveBack()
    if self:hasPastMoves() then
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self:setDirection(lastMove.direction)
    end
end

function Player:hasPastMoves()
    return #self.pastMoves >= 1
end

function Player:moveForward(step)
    if (self.direction == DIRECTIONS.UP) then
        self.position.y -= step
    elseif (self.direction == DIRECTIONS.DOWN) then
        self.position.y += step
    elseif (self.direction == DIRECTIONS.LEFT) then
        self.position.x -= step
    elseif (self.direction == DIRECTIONS.RIGHT) then
        self.position.x += step
    end
end

function Player:move(step, isForward, grid)
    local tile = grid[getTile(self.position.x, self.position.y)]
    tile = EMPTY_TILE
    if isForward then
        self:addPastMove()
        self:moveForward(step)
    else
        self:moveBack()
    end
    self:setPosition()
    if tile ~= LADDER_TILE then
        tile = PLAYER_TILE
    end
end

function Player:setPosition()
    self:moveTo((self.position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (self.position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

local function getDirectionImage(direction)
    if direction == DIRECTIONS.LEFT then
        return PLAYER_IMAGES.left
    elseif direction == DIRECTIONS.RIGHT then
        return PLAYER_IMAGES.right
    elseif direction == DIRECTIONS.UP then
        return PLAYER_IMAGES.up
    elseif direction == DIRECTIONS.DOWN then
        return PLAYER_IMAGES.down
    end
end

function Player:setDirection(direction)
    local image = getDirectionImage(direction)
    self:setImage(image)
    self.direction = direction
end

local function nextTileIsObstacle(grid, x, y)
    local nextTile = grid[getTile(x, y)]
    return not (nextTile == EMPTY_TILE or nextTile == LADDER_TILE or  nextTile == PLAYER_TILE)
end

function Player:onLadder(grid)
    return grid[getTile(self.position.x, self.position.y)] == LADDER_TILE
end

function Player:onLaser(laserBases, turn)
    local allLaserTilePositions = {}
    for i, laserBase in ipairs(laserBases) do
        if laserBase.laser:isVisible(turn) then
            table.insert(allLaserTilePositions, laserBase.laser:getTilePositions())
        end
    end
    for i, positionTable in ipairs(allLaserTilePositions) do
        for y, position in ipairs(positionTable) do
            if position == self.position then
                return true
            end
        end
    end
    return false
end

function Player:setIsBlocked(grid)
    if (self.direction == DIRECTIONS.UP) then
        self.isBlocked = self:upIsBlocked(grid)
    elseif (self.direction == DIRECTIONS.DOWN) then
        self.isBlocked = self:downIsBlocked(grid)
    elseif (self.direction == DIRECTIONS.LEFT) then
        self.isBlocked = self:leftIsBlocked(grid)
    elseif (self.direction == DIRECTIONS.RIGHT) then
        self.isBlocked = self:rightIsBlocked(grid)
    end
end

function Player:upIsBlocked(grid)
    return self.position.y == 1 or nextTileIsObstacle(grid, self.position.x, self.position.y-1)
end

function Player:downIsBlocked(grid)
    return self.position.y == TILES_PER_COLUMN or nextTileIsObstacle(grid, self.position.x, self.position.y+1)
end

function Player:leftIsBlocked(grid)
    return self.position.x == 1 or nextTileIsObstacle(grid, self.position.x-1, self.position.y)
end

function Player:rightIsBlocked(grid)
    return self.position.x == TILES_PER_ROW or nextTileIsObstacle(grid, self.position.x+1, self.position.y)
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) and self.isBlocked then
        self:setDirection(DIRECTIONS.UP)
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.isBlocked then
        self:setDirection(DIRECTIONS.DOWN)
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.isBlocked then
        self:setDirection(DIRECTIONS.LEFT)
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.isBlocked then
        self:setDirection(DIRECTIONS.RIGHT)
    end
end