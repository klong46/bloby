import "CoreLibs/sprites"
import "tile"
import "constants"

class('Wall').extends(Tile)

local image = GFX.image.new('img/wall')

function Wall:init(position)
    Wall.super.init(self, position, image)
    self:add()
end