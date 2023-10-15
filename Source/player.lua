import "CoreLibs/sprites"
import "gameObject"

local PD <const> = playdate
local GFX <const> = PD.graphics

class('Player').extends(GameObject)

function Player:init(position)
    local image = GFX.image.new('img/player')
    Player.super.init(self, image)
    self.position = position
    self:setZIndex(1)
    self:setPlayerPosition()
    self:add()
end

function Player:move(step)
    self.position.y += step
    self:setPlayerPosition()
end

function Player:setPlayerPosition()
    self:moveTo((self.position.x * TileSize) - 9, (self.position.y * TileSize) - 9)
end