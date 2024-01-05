import "CoreLibs/sprites"
import "constants"

class('EscapeTile').extends(SLIB)

local image = GFX.image.new('img/escape_tile')
local ANIMATOR_DURATION = 1000

function EscapeTile:init()
    EscapeTile.super.init(self)
    self.fadeAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 0.5, playdate.easingFunctions.outCubic)
    self.animationFinished = false
    self:moveTo(200, 120)
    self:setZIndex(6)
    self:add()
end

function EscapeTile:update()
    EscapeTile.super.update(self)
    if not self.animationFinished then
        self:setImage(image:fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            ShowFinishScreen()
            self.animationFinished = true
        end
    end
end