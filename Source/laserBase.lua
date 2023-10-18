import "CoreLibs/sprites"
import "tile"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('LaserBase').extends(Tile)

local image = GFX.image.new('img/laser/laser_base')

function LaserBase:init(position, grid, direction)
    LaserBase.super.init(self, position, image)
    self.laser = Laser(position, grid, direction)
    self:add()
end