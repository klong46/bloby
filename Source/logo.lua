import "constants"

class('Logo').extends(SLIB)

local imgTable = GFX.imagetable.new('img/logo_animation')
local ANIMATOR_SPEED = 80
local FADE_SPEED = 1000
local LAST_IMG = imgTable:getImage(imgTable:getLength())
local SHOW_TIME = 3000

function Logo:init()
    Logo.super.init(self)
    self.logoAnimation = GFX.animation.loop.new(ANIMATOR_SPEED, imgTable, false)
    self.fadeAnimator = nil
    self.fadeTimer = nil
    self:moveTo(200, 120)
    self:setZIndex(15)
    self:add()
end

function Logo:update()
    Logo.super.update(self)
    self:setImage(self.logoAnimation:image())
    if not self.logoAnimation:isValid() then
        self:setImage(imgTable:getImage(3))
        self:setImage(LAST_IMG)
        if not self.fadeTimer then
            self.fadeTimer = PD.timer.performAfterDelay(SHOW_TIME, function() self.fadeAnimator = GFX.animator.new(FADE_SPEED, 1, 0) end)
        end
    end
    if self.fadeAnimator then
        self:setImage(LAST_IMG:fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            self:remove()
            InTransition = false
        end
    end
end