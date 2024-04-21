import "CoreLibs/sprites"
import "constants"
import "levelSelectNumber"

local blankTile = GFX.image.new('img/level_tile/blank_tile')

local WIDTH = 80

class('BlankTile').extends(SLIB)

function BlankTile:init(x, y)
    BlankTile.super.init(self)
    self:setImage(blankTile:fadedImage(0.2, GFX.image.kDitherTypeDiagonalLine))
    self:moveTo(x*WIDTH-40, y*WIDTH-40)
    self:add()
end
