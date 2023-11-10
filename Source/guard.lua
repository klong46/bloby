import "CoreLibs/sprites"

local image = GFX.image.new('img/guard')

class('Guard').extends(GameObject)

function Guard:init(position)
    Guard.super.init(self, image)
    self.position = position
    self.direction = DEFAULT_GUARD_DIRECTION
    self.pastMoves = {}
    self.isBlocked = false
    self.alive = true
    self:setDirection(direction)
    self:setPosition()
    self:add()
end

local function getTile(x, y)
    return ((y-1)*TILES_PER_ROW)+x
end

function Guard:addPastMove()
    local newPos = PD.geometry.point.new(self.position.x, self.position.y)
    local newDir = self.direction
    local newAlive = self.alive
    print(newAlive)
    table.insert(self.pastMoves, {position = newPos, direction = newDir, alive = newAlive})
end

function Guard:moveBack()
    if self:hasPastMoves() then
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self.alive = lastMove.alive
        self:setDirection(lastMove.direction)
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
    grid[getTile(self.position.x, self.position.y)] = EMPTY_TILE
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
        grid[getTile(self.position.x, self.position.y)] = GUARD_TILE
    end
end

function Guard:destroy(grid)
    grid[getTile(self.position.x, self.position.y)] = EMPTY_TILE
    self.alive = false
    self:setVisible(false)
end

function Guard:setPosition()
    self:moveTo((self.position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (self.position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

function Guard:setDirection(direction)
    self.direction = direction
end

local function nextTileIsObstacle(grid, x, y)
    local nextTile = grid[getTile(x, y)]
    return not (nextTile == EMPTY_TILE or nextTile == MOUSE_TILE)
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
    return self.position.y == 1 or nextTileIsObstacle(grid, self.position.x, self.position.y-1)
end

function Guard:downIsBlocked(grid)
    return self.position.y == TILES_PER_COLUMN or nextTileIsObstacle(grid, self.position.x, self.position.y+1)
end

function Guard:leftIsBlocked(grid)
    return self.position.x == 1 or nextTileIsObstacle(grid, self.position.x-1, self.position.y)
end

function Guard:rightIsBlocked(grid)
    return self.position.x == TILES_PER_ROW or nextTileIsObstacle(grid, self.position.x+1, self.position.y)
end