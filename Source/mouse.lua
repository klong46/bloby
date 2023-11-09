import "CoreLibs/sprites"
import "gameObject"
import "constants"

local image = GFX.image.new('img/mouse')

class('Mouse').extends(GameObject)

function Mouse:init(position)
    Mouse.super.init(self, image)
    self.position = position
    self.direction = DEFAULT_MOUSE_DIRECTION
    self.pastMoves = {}
    self.isBlocked = false
    self.active = false
    self:setDirection(direction)
    self.canTurn = false
    self:setZIndex(1)
    self:setPosition()
    self:add()
end

local function getTile(x, y)
    return ((y-1)*TILES_PER_ROW)+x
end

function Mouse:addPastMove()
    local newPos = PD.geometry.point.new(self.position.x, self.position.y)
    local newDir = self.direction
    local isBlocked = false
    table.insert(self.pastMoves, {position = newPos, direction = newDir, isBlocked = isBlocked})
end

function Mouse:moveBack()
    if self:hasPastMoves() then
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self:setDirection(lastMove.direction)
    end
end

function Mouse:hasPastMoves()
    return #self.pastMoves >= 1
end

function Mouse:moveForward(playerPosition)
    self.position = playerPosition
end

function Mouse:move(playerPosition, isForward)
    if isForward then
        self:addPastMove()
        self:moveForward(playerPosition)
    else
        self:moveBack()
    end
    self:setPosition()
end

function Mouse:setPosition()
    self:moveTo((self.position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (self.position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

function Mouse:setDirection(direction)
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

function Mouse:onLadder(grid)
    return grid[getTile(self.position.x, self.position.y)] == LADDER_TILE
end

function Mouse:onLaser(laserBases, turn)
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

function Mouse:setIsBlocked(grid)
    self.isBlocked = nextTileIsObstacle(grid, self.position.x, self.position.y, self.direction)
end

function Mouse:update()
    Mouse.super.update(self)
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