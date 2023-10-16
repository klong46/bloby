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

local function nextTileWall(grid, x, y)
    return grid[(y-1)*TilesPerRow+x] == 1
end

function Player:onLadder(grid)
    return grid[(self.position.y-1)*TilesPerRow+self.position.x] == 4
end

function Player:moveValid(grid)
    local x = self.position.x
    local y = self.position.y
    if (self.direction == 'up') then
        y -= 1
        return not (self.position.y == 1 or nextTileWall(grid, x, y))
    elseif (self.direction == 'down') then
        y += 1
        return not (self.position.y == TilesPerColumn or nextTileWall(grid, x, y))
    elseif (self.direction == 'left') then
        x -= 1
        return not (self.position.x == 1 or nextTileWall(grid, x, y))
    elseif (self.direction == 'right') then
        x += 1
        return not (self.position.x == TilesPerRow or nextTileWall(grid, x, y))
    end
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) then
        self:changeDirection(PLAYER_IMAGES.up, 'up')
    end
    if PD.buttonIsPressed(PD.kButtonDown) then
        self:changeDirection(PLAYER_IMAGES.down, 'down')
    end
    if PD.buttonIsPressed(PD.kButtonLeft) then
        self:changeDirection(PLAYER_IMAGES.left, 'left')
    end
    if PD.buttonIsPressed(PD.kButtonRight) then
        self:changeDirection(PLAYER_IMAGES.right, 'right')
    end
end