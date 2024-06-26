import "constants"

class('Panel').extends(SLIB)

function Panel:init(levelNum)
    Panel.super.init(self)
    local image = GFX.image.new('img/panels/'..levelNum)
    self:setImage(image)
    self:moveTo(205, 120)
    self:setZIndex(10)
    self:add()
end