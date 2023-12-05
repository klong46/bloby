import "CoreLibs/sprites"
import "constants"

class('StaticObject').extends(SLIB)

function StaticObject:init(image, position)
    StaticObject.super.init(self)
    self:setImage(image)
    self:moveTo((position.x * TILE_SIZE) - 10, (position.y * TILE_SIZE) - 10)
    self:add()
end
