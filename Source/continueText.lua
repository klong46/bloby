import "CoreLibs/sprites"
import "constants"

local image = GFX.image.new("img/continue_button")
local ANIMATION_DURATION = 500

class('ContinueText').extends(SLIB)

local function invert(self)
    self:markDirty()
    image:setInverted(self.inverted)
    self:setImage(image)
    self.inverted = not self.inverted
end

function ContinueText:init()
    ContinueText.super.init(self)
    self.image = image
    self.inverted = false
    self:setImage(image)
    self:moveTo(375, 215)
    self:setZIndex(10)
    local invertTimer = PD.timer.keyRepeatTimerWithDelay(ANIMATION_DURATION, ANIMATION_DURATION, invert, self)
    self:add()
    ReadyToContinue = true
end
