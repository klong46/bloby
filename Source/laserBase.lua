import "CoreLibs/sprites"
import "constants"

class('LaserBase').extends(StaticObject)

local image = GFX.image.new('img/laser/laser_base')

function LaserBase:init(position, grid, direction, cadence, offset)
    LaserBase.super.init(self, image, position)
    self.laser = Laser(position, grid, direction, cadence, offset)
end