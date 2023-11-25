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
    if dir ~= self.lastDirection then
        blocked = true
        self.lastDirection = dir
    end
    table.insert(self.pastMoves, {position = pos,
                                  direction = dir,
                                  delay = del,
                                  isBlocked = blocked,
                                  alive = living})
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
        {"Y", -step},
        {"Y", step},
        {"X", -step},
        {"X", step}
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
        {x, y - 1},
        {x, y + 1},
        {x - 1, y},
        {x + 1, y}
    }
    return GetByDirection(tileList, self.direction)
end

function DynamicObject:nextTileIsObstacle(x, y)
    local nextPosition = self:getNextTilePosition(x, y)
    local nextTile = self.grid[(GetTile(nextPosition[1], nextPosition[2]))]
    if nextTile == WALL_TILE or nextTile == nil or x > TILES_PER_ROW or x < 1 then
        return true
    elseif nextTile == GUARD_TILE then
        local adjacentPosition = self:getNextTilePosition(x, y)
        self:nextTileIsObstacle(adjacentPosition[1], adjacentPosition[2])

        -- if self.direction == DIRECTIONS.UP then
        --     return self:nextTileIsObstacle(x, y-1)
        -- elseif self.direction == DIRECTIONS.DOWN then
        --     return self:nextTileIsObstacle(x, y+1)
        -- elseif self.direction == DIRECTIONS.LEFT then
        --     return self:nextTileIsObstacle(x-1, y)
        -- elseif self.direction == DIRECTIONS.RIGHT then
        --     return self:nextTileIsObstacle(x+1, y)
        -- end
    elseif nextTile == EMPTY_TILE or nextTile == MOUSE_TILE or tile == LADDER_TILE then
        return false
    end
end