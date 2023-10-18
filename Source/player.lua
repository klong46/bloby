import "CoreLibs/sprites"
import "gameObject"

local PD <const> = playdate
local GFX <const> = PD.graphics
local PLAYER_IMAGES <const> = {
    up = GFX.image.new('img/player/player_up'),
    down = GFX.image.new('img/player/player_down'),
    left = GFX.image.new('img/player/player_left'),
    right = GFX.image.new('img/player/player_right')
}

class('Player').extends(GameObject)

function Player:init(position)
    local image = PLAYER_IMAGES.down
    Player.super.init(self, image)
    self.position = position
    self.direction = 'down'
    self.canTurn = false
    self:setZIndex(1)
    self:setPlayerPosition()
    self:add()
end

function Player:move(step)
    if (self.direction == 'up') then
        self.position.y -= step
    elseif (self.direction == 'down') then
        self.position.y += step
    elseif (self.direction == 'left') then
        self.position.x -= step
    elseif (self.direction == 'right') then
        self.position.x += step
    end
    self:setPlayerPosition()
end

function Player:setPlayerPosition()
    self:moveTo((self.position.x * TileSize) - 9, (self.position.y * TileSize) - 9)
end

function Player:changeDirection(image, direction)
    self:setImage(image)
    self.direction = direction
end

local function nextTileIsObstacle(grid, x, y)
    local nextTile = grid[(y-1)*TilesPerRow+x]
    return nextTile == 1 or nextTile == 2 or nextTile == 5
end

function Player:onLadder(grid)
    return grid[(self.position.y-1)*TilesPerRow+self.position.x] == 4
end

function Player:onLaser(grid)
    -- return grid[(self.position.y-1)*TilesPerRow+self.position.x] == 2
    return false
end

function Player:moveValid(grid)
    local isBlocked
    if (self.direction == 'up') then
        isBlocked = self.position.y == 1 or nextTileIsObstacle(grid, self.position.x, self.position.y-1)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == 'down') then
        isBlocked = self.position.y == TilesPerColumn or nextTileIsObstacle(grid, self.position.x, self.position.y+1)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == 'left') then
        isBlocked = self.position.x == 1 or nextTileIsObstacle(grid, self.position.x-1, self.position.y)
        self:setCanTurn(isBlocked)
        return not isBlocked
    elseif (self.direction == 'right') then
        isBlocked = self.position.x == TilesPerRow or nextTileIsObstacle(grid, self.position.x+1, self.position.y)
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
        self:changeDirection(PLAYER_IMAGES.up, 'up')
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.canTurn then
        self:changeDirection(PLAYER_IMAGES.down, 'down')
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.canTurn then
        self:changeDirection(PLAYER_IMAGES.left, 'left')
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.canTurn then
        self:changeDirection(PLAYER_IMAGES.right, 'right')
    end
end