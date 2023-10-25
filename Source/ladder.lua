import "CoreLibs/sprites"
import "tile"
import "constants"

class('Ladder').extends(Tile)

function Ladder:init(position)
    local image = GFX.image.new('img/ladder')
    Ladder.super.init(self, position, image)
    self:moveTo((position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
    self:add()
end