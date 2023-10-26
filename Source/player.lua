import "CoreLibs/sprites"
import "gameObject"
import "constants"

local PLAYER_IMAGES <const> = {
    up = GFX.image.new('img/player/player_up'),
    down = GFX.image.new('img/player/player_down'),
    left = GFX.image.new('img/player/player_left'),
    right = GFX.image.new('img/player/player_right')
}

class('Player').extends(GameObject)

function Player:init(position, direction)
    local image = PLAYER_IMAGES.down
    Player.super.init(self, image)
    self.position = position
    self.direction = direction
    self:setDirection(direction)
    self.canTurn = false
    self:setZIndex(1)
    self:setPlayerPosition()
    self:add()
end

function Player:move(step)
    if (self.direction == DIRECTIONS.UP) then
        self.position.y -= step
    elseif (self.direction == DIRECTIONS.DOWN) then
        self.position.y += step
    elseif (self.direction == DIRECTIONS.LEFT) then
        self.position.x -= step
    elseif (self.direction == DIRECTIONS.RIGHT) then
        self.position.x += step
    end
    self:setPlayerPosition()
end

function Player:setPlayerPosition()
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
    local nextTile = grid[(y-1)*TILES_PER_ROW+x]
    return not (nextTile == EMPTY_TILE or nextTile == LADDER_TILE)
end

function Player:onLadder(grid)
    return grid[(self.position.y-1)*TILES_PER_ROW+self.position.x] == LADDER_TILE
end

function Player:onLaser(laserBases, turn)
    local allLaserTilePosition = {}
    for i, laserBase in ipairs(laserBases) do
        if laserBase.laser:isVisible(turn) then
            table.insert( allLaserTilePosition, laserBase.laser:getTilePositions() )
        end
    end
    for i, positionTable in ipairs(allLaserTilePosition) do
        for y, position in ipairs(positionTable) do
            if position == self.position then
                return true
            end
        end
    end
    return false
end

function Player:moveValid(grid)
    local isBlocked
    if (self.direction == DIRECTIONS.UP) then
        isBlocked = self.position.y == 1 or nextTileIsObstacle(grid, self.position.x, self.position.y-1)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == DIRECTIONS.DOWN) then
        isBlocked = self.position.y == TILES_PER_COLUMN or nextTileIsObstacle(grid, self.position.x, self.position.y+1)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == DIRECTIONS.LEFT) then
        isBlocked = self.position.x == 1 or nextTileIsObstacle(grid, self.position.x-1, self.position.y)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == DIRECTIONS.RIGHT) then
        isBlocked = self.position.x == TILES_PER_ROW or nextTileIsObstacle(grid, self.position.x+1, self.position.y)
        self:setCanTurn(isBlocked)
        return not isBlocked
    end
end

function Player:setCanTurn(isBlocked)
    self.canTurn = isBlocked -- player can only turn when stopped by obstacle
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) and self.canTurn then
        self:setDirection(DIRECTIONS.UP)
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.canTurn then
        self:setDirection(DIRECTIONS.DOWN)
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.canTurn then
        self:setDirection(DIRECTIONS.LEFT)
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.canTurn then
        self:setDirection(DIRECTIONS.RIGHT)
    end
end