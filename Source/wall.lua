import "CoreLibs/sprites"
import "staticObject"
import "constants"

class('Wall').extends(StaticObject)

local image = GFX.image.new('img/wall')

function Wall:init(position)
    Wall.super.init(self, image, position)
    self:setZIndex(1)
    self:add()
end