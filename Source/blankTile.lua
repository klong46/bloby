import "constants"

class('BlankTile').extends(SLIB)

local blankTile = GFX.image.new('img/level_tile/blank_tile')
local WIDTH = 80
local OFFSET = 40
local FADE_STRENGTH = 0.5

function BlankTile:init(x, y)
    BlankTile.super.init(self)
    self:setImage(blankTile:fadedImage(FADE_STRENGTH, GFX.image.kDitherTypeScreen))
    self:moveTo(x*WIDTH-OFFSET, y*WIDTH-OFFSET)
    self:add()
end
