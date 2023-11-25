import "CoreLibs/sprites"
import "dynamicObject"

local GUARD_IMAGES <const> = {
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard')
}

class('Guard').extends(DynamicObject)

function Guard:init(position, grid)
    Guard.super.init(self, GUARD_IMAGES[1], position, DEFAULT_GUARD_DIRECTION, grid, GUARD_IMAGES)
    self.alive = true
    self.lastPosition = position
end

function Guard:moveBack()
    local lastMove = Guard.super.moveBack(self)
    if lastMove then
        self.alive = lastMove.alive
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

function Guard:move(step, isForward)
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
        self.grid[GetTile(self.position.x, self.position.y)] = GUARD_TILE
    end
end

function Guard:destroy()
    self.grid[GetTile(self.position.x, self.position.y)] = EMPTY_TILE
    self.alive = false
    self:setVisible(false)
end

-- FIX COLLISIONS WITH EVERYTHING
function Guard:nextTileIsObstacle(x, y)
    local nextTile = self.grid[GetTile(x, y)]
    if nextTile == WALL_TILE or nextTile == nil or x > TILES_PER_ROW or x < 1 then
        return true
    elseif nextTile == GUARD_TILE then
        if self.direction == DIRECTIONS.UP then
            return self:nextTileIsObstacle(x, y-1)
        elseif self.direction == DIRECTIONS.DOWN then
            return self:nextTileIsObstacle(x, y+1)
        elseif self.direction == DIRECTIONS.LEFT then
            return self:nextTileIsObstacle(x-1, y)
        elseif self.direction == DIRECTIONS.RIGHT then
            return self:nextTileIsObstacle(x+1, y)
        end
    elseif nextTile == EMPTY_TILE or nextTile == MOUSE_TILE then
        return false
    end
end

function Guard:setIsBlocked()
    if (self.direction == DIRECTIONS.UP) then
        self.isBlocked = self:upIsBlocked()
    elseif (self.direction == DIRECTIONS.DOWN) then
        self.isBlocked = self:downIsBlocked()
    elseif (self.direction == DIRECTIONS.LEFT) then
        self.isBlocked = self:leftIsBlocked()
    elseif (self.direction == DIRECTIONS.RIGHT) then
        self.isBlocked = self:rightIsBlocked()
    end
end

function Guard:upIsBlocked()
    return self.position.y == 1 or self:nextTileIsObstacle(self.position.x, self.position.y-1)
end

function Guard:downIsBlocked()
    return self.position.y == TILES_PER_COLUMN or self:nextTileIsObstacle(self.position.x, self.position.y+1)
end

function Guard:leftIsBlocked()
    return self.position.x == 1 or self:nextTileIsObstacle(self.position.x-1, self.position.y)
end

function Guard:rightIsBlocked()
    return self.position.x == TILES_PER_ROW or self:nextTileIsObstacle(self.position.x+1, self.position.y)
end