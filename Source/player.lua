import "CoreLibs/sprites"
import "dynamicObject"
import "constants"

local PLAYER_IMAGES <const> = {
    GFX.image.new('img/player/player_up'),
    GFX.image.new('img/player/player_down'),
    GFX.image.new('img/player/player_left'),
    GFX.image.new('img/player/player_right')
}

local lastDirection

class('Player').extends(DynamicObject)

function Player:init(position, direction, grid)
    Player.super.init(self, PLAYER_IMAGES[1], position, direction, grid)
    self.pastMoves = {}
    self:setDirectionImage(PLAYER_IMAGES, direction)
    lastDirection = direction
    self.canTurn = false
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
        lastDirection = self.pastMoves[#self.pastMoves].direction
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self:setDirectionImage(PLAYER_IMAGES, lastMove.direction)
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
    self:setPosition(self.position)
end



-- local function isObstacle(tile)
--     return not (tile == EMPTY_TILE or tile == LADDER_TILE or tile == MOUSE_TILE)
-- end

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

function Player:nextTileIsObstacle(grid, x, y)
    local nextTile = grid[GetTile(x, y)]
    -- print(nextTile)
    if nextTile == WALL_TILE or nextTile == nil or x > TILES_PER_ROW or x < 1 then
        return true
    elseif nextTile == GUARD_TILE then
        if self.direction == DIRECTIONS.UP then
            return self:nextTileIsObstacle(grid, x, y-1)
        elseif self.direction == DIRECTIONS.DOWN then
            return self:nextTileIsObstacle(grid, x, y+1)
        elseif self.direction == DIRECTIONS.LEFT then
            return self:nextTileIsObstacle(grid, x-1, y)
        elseif self.direction == DIRECTIONS.RIGHT then
            return self:nextTileIsObstacle(grid, x+1, y)
        end
    elseif nextTile == EMPTY_TILE or nextTile == MOUSE_TILE or tile == LADDER_TILE then
        return false
    end
end

function Player:onLadder()
    return self.grid[GetTile(self.position.x, self.position.y)] == LADDER_TILE
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

function Player:onMouse(mice)
    for i, mouse in ipairs(mice) do
        local lastPosition = self.pastMoves[#self.pastMoves].position
        local lastMousePosition = mouse.pastMoves[#mouse.pastMoves].position
        if ((mouse.position == self.position) or
           ((mouse.position == lastPosition) and (lastMousePosition == self.position))) and
           (mouse.delay == 0) then
            return true
        end
    end
    return false
end

function Player:setIsBlocked(grid)
    local nextPos = getNextTilePosition(self.position.x, self.position.y, self.direction)
    self.isBlocked = self:nextTileIsObstacle(grid, nextPos.x, nextPos.y)
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) and self.isBlocked then
        self:setDirectionImage(PLAYER_IMAGES, DIRECTIONS.UP)
        self.direction = DIRECTIONS.UP
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.isBlocked then
        self:setDirectionImage(PLAYER_IMAGES, DIRECTIONS.DOWN)
        self.direction = DIRECTIONS.DOWN
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.isBlocked then
        self:setDirectionImage(PLAYER_IMAGES, DIRECTIONS.LEFT)
        self.direction = DIRECTIONS.LEFT
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.isBlocked then
        self:setDirectionImage(PLAYER_IMAGES, DIRECTIONS.RIGHT)
        self.direction = DIRECTIONS.RIGHT
    end
end
