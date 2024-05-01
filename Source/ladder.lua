import "staticObject"
import "constants"

class('Ladder').extends(StaticObject)

local animationTable = GFX.imagetable.new('img/ladder_animation')
local ANIMATION_SPEED = 120
local ANIMATOR_DURATION = 2500

function Ladder:init(position)
    Ladder.super.init(self, image, position)
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, animationTable, true)
    self.fadeAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 1)
    self.fadeAnimator.paused = true
end

function Ladder:update()
    Ladder.super.update(self)
    if self.fadeAnimator.paused then
        self:setImage(self.animation:image())
    else
        self:setImage(self.animation:image():fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            self.fadeAnimator.paused = true
        end
    end
end

function Ladder:show()
    self:setVisible(true)
    self.fadeAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 1)
    self.fadeAnimator.paused = false
end

function Ladder:hide()
    self:setVisible(false)
    self.fadeAnimator.paused = true
end
