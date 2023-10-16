import "CoreLibs/sprites"
import "tile"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Wall').extends(Tile)

local image = GFX.image.new('img/wall')

function Wall:init(position)
    Wall.super.init(self, position, image)
    self:add()
end