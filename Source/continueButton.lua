import "constants"

class('ContinueButton').extends(SLIB)

local FRAME_RATE = 200
local POSITION = {X = 375, Y = 215}
local buttonPressAnimationTable = GFX.imagetable.new('img/button_press_animation')

function ContinueButton:init()
    ContinueButton.super.init(self)
    self.pressAnimation = GFX.animation.loop.new(FRAME_RATE, buttonPressAnimationTable, true)
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(6)
    self:add()
    ReadyToContinue = true
end

function ContinueButton:update()
    ContinueButton.super.update(self)
    self:setImage(self.pressAnimation:image())
end
