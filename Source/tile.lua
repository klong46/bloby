import "CoreLibs/sprites"
import "gameObject"
import "constants"

class('Tile').extends(GameObject)

function Tile:init(position, image)
    Tile.super.init(self, image)
    self:moveTo((position.x * TILE_SIZE) - 10, (position.y * TILE_SIZE) - 10)
    self:setImage(image)
    self:add()
end