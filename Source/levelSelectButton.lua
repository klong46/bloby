import "CoreLibs/sprites"
import "constants"

local image = GFX.image.new('img/level_select_button')

class('LevelSelectButton').extends(SLIB)

function LevelSelectButton:init()
    LevelSelectButton.super.init(self)
    self:setImage(image)
    self:moveTo(270, 160)
    self:setZIndex(6)
    self:add()
end

