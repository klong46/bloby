import "CoreLibs/sprites"
import "constants"

class('DynamicObject').extends(SLIB)

function DynamicObject:init(initImage, position, direction, grid, imageList)
    DynamicObject.super.init(self)
    self.direction = direction
    self.position = position
    self.isBlocked = false
    self.grid = grid
    self.pastMoves = {}
    self.lastDirection = direction
    self.imageList = imageList

    self:setImage(initImage)
    self:setPosition()
    self:add()
end

function DynamicObject:setPosition()
    self:moveTo((self.position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (self.position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

function DynamicObject:setDirectionImage(direction)
    self:setImage(GetByDirection(self.imageList, direction))
end

function DynamicObject:hasPastMoves()
    return #self.pastMoves >= 1
end

function DynamicObject:addPastMove()
    local pos = PD.geometry.point.new(self.position.x, self.position.y)
    local dir = self.direction
    local del = self.delay
    local blocked = false
    local living = self.alive
    local st = self.stalledTurns
    local isStalled = self.stalled
    if dir ~= self.lastDirection then
        blocked = true
        self.lastDirection = dir
    end
    table.insert(self.pastMoves, {
        position = pos,
        direction = dir,
        delay = del,
        isBlocked = blocked,
        alive = living,
        stalledTurns = st,
        stalled = isStalled
    })
end

function DynamicObject:moveBack()
    if self:hasPastMoves() then
        self.lastDirection = self.pastMoves[#self.pastMoves].direction
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self:setDirectionImage(lastMove.direction)
        self.direction = lastMove.direction
        return lastMove
    end
end

function DynamicObject:moveForward(step)
    local moveList = {
        { "Y", -step },
        { "Y", step },
        { "X", -step },
        { "X", step }
    }
    local move = GetByDirection(moveList, self.direction)
    if move[1] == "Y" then
        self.position.y += move[2]
    else
        self.position.x += move[2]
    end
end

function DynamicObject:getNextTilePosition(x, y)
    local tileList = {
        { x,     y - 1 },
        { x,     y + 1 },
        { x - 1, y },
        { x + 1, y }
    }
    return GetByDirection(tileList, self.direction)
end

function DynamicObject:nextTileIsObstacle(x, y, obstacles)
    local nextPosition = self:getNextTilePosition(x, y)
    local nextTile = self.grid[(GetTile(nextPosition[1], nextPosition[2]))]
    if nextTile == GUARD_TILE then
        local adjacentPosition = self:getNextTilePosition(x, y)
        return self:nextTileIsObstacle(adjacentPosition[1], adjacentPosition[2], GUARD_OBSTACLES)
    elseif self:isObstacleTile(nextTile, obstacles) or
        nextPosition[1] > TILES_PER_ROW or
        nextPosition[1] < 1 or
        nextPosition[2] > TILES_PER_COLUMN or
        nextPosition[2] < 1 then
        return true
    else
        return false
    end
end

function DynamicObject:setIsBlocked(obstacles)
    self.isBlocked = self:nextTileIsObstacle(self.position.x, self.position.y, obstacles)
end

function DynamicObject:isObstacleTile(tile, obstacles)
    for i, obstacle in ipairs(obstacles) do
        if obstacle == tile then
            return true
        end
    end
    return false
end

function DynamicObject:onLaser(laserBases, turn)
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

function DynamicObject:onMouse(mice, isForward)
    for i, mouse in ipairs(mice) do
        if #self.pastMoves > 0 then
            local lastPosition = self.pastMoves[#self.pastMoves].position
            local lastMousePosition = mouse.pastMoves[#mouse.pastMoves].position
            if ((mouse.position == self.position) or
                    ((mouse.position == lastPosition) and (lastMousePosition == self.position))) and
                (mouse.delay == 0) then
                if isForward then
                    mouse.eating = true
                    -- print('EAT')
                end
                if self:isa(Player) then
                    mouse.gameOver = true
                end
                return true
            end
        end
    end
    return false
end
