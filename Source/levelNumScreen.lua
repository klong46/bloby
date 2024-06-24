import "constants"
import "levelNumScreenText"

class('LevelNumScreen').extends(SLIB)

local image = GFX.image.new('img/escape_tile')
local ANIMATOR_DURATION = 320
local POSITION = {X = 200, Y = 120}


function LevelNumScreen:init(levelNum)
    LevelNumScreen.super.init(self)
    self.dismissed = false
    self:setImage(image:fadedImage(0.5, GFX.image.kDitherTypeBayer8x8))
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(11)
    self.text = LevelNumScreenText(levelNum)
    self:add()
end

function LevelNumScreen:update()
    LevelNumScreen.super.update(self)
    if self.dismissed then
        if not self.fadeAnimator then
            self.fadeAnimator = GFX.animator.new(ANIMATOR_DURATION, 0.5, 0)
        end
        self:setImage(image:fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            self:remove()
        end
    end
end