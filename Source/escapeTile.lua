import "constants"

class('EscapeTile').extends(SLIB)

local image = GFX.image.new('img/escape_tile')
local ANIMATOR_DURATION = 1000
local FADE_STRENGTH = 0.5
local POSITION = {X = 200, Y = 120}
local stars

function EscapeTile:init(starsEarned)
    EscapeTile.super.init(self)
    self.fadeAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, FADE_STRENGTH, playdate.easingFunctions.outCubic)
    stars = starsEarned
    self.animationFinished = false
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(6)
    self:add()
end

function EscapeTile:update()
    EscapeTile.super.update(self)
    if not self.animationFinished then
        self:setImage(image:fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            ShowFinishScreen(stars)
            self.animationFinished = true
        end
    end
end