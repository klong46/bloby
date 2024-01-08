import "CoreLibs/sprites"
import "constants"

local FRAME_RATE = 200
local buttonPressAnimationTable = GFX.imagetable.new('img/button_press_animation')

class('ButtonIcon').extends(SLIB)

function ButtonIcon:init()
    ButtonIcon.super.init(self)
    self.pressAnimation = GFX.animation.loop.new(FRAME_RATE, buttonPressAnimationTable, true)
    self:moveTo(375, 215)
    self:setZIndex(6)
    self:add()
    ReadyToContinue = true
end

function ButtonIcon:update()
    ButtonIcon.super.update(self)
    self:setImage(self.pressAnimation:image())
end
