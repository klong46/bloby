import "CoreLibs/sprites"
import "staticObject"
import "constants"

class('Ladder').extends(StaticObject)

local image = GFX.image.new('img/ladder')

function Ladder:init(position)
    Ladder.super.init(self, image, position)
end