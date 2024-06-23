import "constants"

class('Eyelid').extends(SLIB)

local eyelidImage = GFX.image.new('img/game_win/eyelid')

function Eyelid:init(x, y)
    Eyelid.super.init(self)
    self:moveTo(x, y)
    self:setImage(eyelidImage)
    self:setZIndex(1)
    self:add()
end
