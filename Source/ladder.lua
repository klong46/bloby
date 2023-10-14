import "CoreLibs/sprites"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Ladder').extends(SLIB)

local image = GFX.image.new('img/ladder')

function Ladder:init(position)
    Ladder.super.init(self)
    self:moveTo((position.x * TileSize) - 9, (position.y * TileSize) - 9)
    self:setImage(image)
    self:add()
end