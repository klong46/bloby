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
        lastDirection = lastMove.direction
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

function Player:move(step, isForward)
    if isForward then
        self:addPastMove()
        self:moveForward(step)
    else
        self:moveBack()
    end
    self:setPosition()
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

local function isObstacle(tile)
    return not (tile == EMPTY_TILE or tile == LADDER_TILE)
end

local function getNextTilePosition(x, y, direction)
    if (direction == DIRECTIONS.UP) then
        y -= 1
    elseif (direction == DIRECTIONS.DOWN) then
        y += 1
    elseif (direction == DIRECTIONS.LEFT) then
        x -= 1
    elseif (direction == DIRECTIONS.RIGHT) then
        x += 1
    end
    return PD.geometry.point.new(x, y)
end

local function onBorder(x, y, direction)
    if (direction == DIRECTIONS.UP) then
        return y < 1
    elseif (direction == DIRECTIONS.DOWN) then
        return y > TILES_PER_COLUMN
    elseif (direction == DIRECTIONS.LEFT) then
        return x < 1
    elseif (direction == DIRECTIONS.RIGHT) then
        return x > TILES_PER_ROW
    end
end

local function nextTileIsObstacle(grid, x, y, direction)
    local nextTilePosition = getNextTilePosition(x, y, direction)
    local nextTile = grid[getTile(nextTilePosition.x, nextTilePosition.y)]
    if nextTile == GUARD_TILE then
        nextTilePosition = getNextTilePosition(nextTilePosition.x, nextTilePosition.y, direction)
        nextTile = grid[getTile(nextTilePosition.x, nextTilePosition.y)]
    end
    return isObstacle(nextTile) or onBorder(nextTilePosition.x, nextTilePosition.y, direction)
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
    self.isBlocked = nextTileIsObstacle(grid, self.position.x, self.position.y, self.direction)
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