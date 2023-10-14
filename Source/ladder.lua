import "CoreLibs/sprites"
import "tile"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Ladder').extends(Tile)

function Ladder:init(position)
    local image = GFX.image.new('img/ladder')
    Ladder.super.init(self, position, image)
    self:moveTo((position.x * TileSize) - 9, (position.y * TileSize) - 9)
    self:add()
end