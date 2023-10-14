import "CoreLibs/sprites"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Tile').extends(SLIB)

function Tile:init(position, image)
    Tile.super.init(self)
    self:moveTo((position.x * TileSize) - 10, (position.y * TileSize) - 10)
    self:setImage(image)
    self:add()
end