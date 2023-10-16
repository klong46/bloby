import "CoreLibs/sprites"
import "tile"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('LaserBase').extends(Tile)

local image = GFX.image.new('img/laser_base')

function LaserBase:init(position)
    LaserBase.super.init(self, position, image)
    self:add()
end