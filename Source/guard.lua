import "CoreLibs/sprites"
import "dynamicObject"

local image = GFX.image.new('img/guard')

class('Guard').extends(DynamicObject)

function Guard:init(position, grid)
    Guard.super.init(self, image, position, DEFAULT_GUARD_DIRECTION, grid)
    self.pastMoves = {}
    self.alive = true
    self.lastPosition = position
end

function Guard:addPastMove()
    local newPos = PD.geometry.point.new(self.position.x, self.position.y)
    local newDir = self.direction
    local newAlive = self.alive
    table.insert(self.pastMoves, {position = newPos, direction = newDir, alive = newAlive})
end

function Guard:moveBack()
    if self:hasPastMoves() then
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self.alive = lastMove.alive
        self.direction = lastMove.direction
    end
end

function Guard:onMouse(mice)
    for i, mouse in ipairs(mice) do
        local lastPosition = self.pastMoves[#self.pastMoves].position
        if ((mouse.position == self.position) or
           (mouse.position == lastPosition)) and
           (mouse.delay == 0) then
            return true
        end
    end
    return false
end

function Guard:hasPastMoves()
    return #self.pastMoves >= 1
end

function Guard:moveForward(step)
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


function Guard:move(step, isForward, grid)
    self.lastPosition = PD.geometry.point.new(self.position.x, self.position.y)
    if isForward then
        self:addPastMove()
        if (not self.isBlocked) and (self.alive) then
            self:moveForward(step)
        end
    else
        self:moveBack()
        if self.alive then
            self:setVisible(true)
        end
    end
    self:setPosition()
    if self.alive then
        grid[GetTile(self.position.x, self.position.y)] = GUARD_TILE
    end
end

function Guard:destroy(grid)
    grid[GetTile(self.position.x, self.position.y)] = EMPTY_TILE
    self.alive = false
    self:setVisible(false)
end

function Guard:setPosition()
    self:moveTo((self.position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (self.position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

-- FIX COLLISIONS WITH EVERYTHING
function Guard:nextTileIsObstacle(grid, x, y)
    local nextTile = grid[GetTile(x, y)]
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
    elseif nextTile == EMPTY_TILE or nextTile == MOUSE_TILE then
        return false
    end
end

function Guard:setIsBlocked(grid)
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

function Guard:upIsBlocked(grid)
    return self.position.y == 1 or self:nextTileIsObstacle(grid, self.position.x, self.position.y-1)
end

function Guard:downIsBlocked(grid)
    return self.position.y == TILES_PER_COLUMN or self:nextTileIsObstacle(grid, self.position.x, self.position.y+1)
end

function Guard:leftIsBlocked(grid)
    return self.position.x == 1 or self:nextTileIsObstacle(grid, self.position.x-1, self.position.y)
end

function Guard:rightIsBlocked(grid)
    return self.position.x == TILES_PER_ROW or self:nextTileIsObstacle(grid, self.position.x+1, self.position.y)
end