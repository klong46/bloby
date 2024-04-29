import "eyelid"

class('GameWinScreen').extends(SLIB)

local GW_IMAGES <const> = {
    GFX.image.new('img/game_win/gw_up'),
    GFX.image.new('img/game_win/gw_down'),
    GFX.image.new('img/game_win/gw_left'),
    GFX.image.new('img/game_win/gw_right')
}

local blackScreen = GFX.image.new('img/game_win/black_screen')

local EYES_CLOSED_Y_POS = 42
local FADE_DURATION = 10000

function GameWinScreen:init()
    GameWinScreen.super.init(self)
    self:moveTo(200,120)
    self:setImage(GW_IMAGES[4])
    self.topEyelid = Eyelid(200, -14)
    self.bottomEyelid = Eyelid(200, 200)
    self.fadeAnimator = GFX.animator.new(FADE_DURATION, 1, 0, PD.easingFunctions.inQuad)
    self.fadeAnimator.paused = true
    self.closed = false
    self:add()
end

function GameWinScreen:up()
    self:setImage(GW_IMAGES[1])
end

function GameWinScreen:down()
    self:setImage(GW_IMAGES[2])
end

function GameWinScreen:left()
    self:setImage(GW_IMAGES[3])
end

function GameWinScreen:right()
    self:setImage(GW_IMAGES[4])
end

function GameWinScreen:moveEyelids()
    self.topEyelid:moveTo(self.topEyelid.x, self.topEyelid.y + (CrankTicks * 2))
    self.bottomEyelid:moveTo(self.bottomEyelid.x, self.bottomEyelid.y - (CrankTicks * 2))
end

function GameWinScreen:update()
    GameWinScreen.super.update(self)
    if CrankTicks < 0 then
        if self.topEyelid.y > -20 then
            self:moveEyelids()
        end
    elseif CrankTicks > 0 then
        self:moveEyelids()
    end
    if self.topEyelid.y >= EYES_CLOSED_Y_POS and not self.closed then
        self:setImage(blackScreen)
        self:setZIndex(2)
        self.topEyelid:remove()
        self.bottomEyelid:remove()
        self.closed = true
        self.fadeAnimator:reset()
    end
    if self.closed then
        self:setImage(self:getImage():fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBayer8x8))
        if self.fadeAnimator:ended() then
            ReturnToMenu()
        end
    end
end