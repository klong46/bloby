import "CoreLibs/sprites"
import "CoreLibs/timer"
import "staticObject"
import "constants"
import "star"

local ANIMATION_DURATION = 500
local starNum = 1
local limit = 0
local starTimer = nil

class('Stars').extends(SLIB)

function Stars:init(num)
    Stars.super.init(self)
    starNum = 1
    limit = num
    self.starAppearTimer = PD.timer.performAfterDelay(ANIMATION_DURATION, self.startAnimation)
end

local function drawStar()
    if starNum <= limit then
        Star(starNum)
        starNum += 1
    else
        if starTimer then
            starTimer:remove()
        end
    end
end

function Stars:startAnimation()
    starTimer = PD.timer.keyRepeatTimerWithDelay(ANIMATION_DURATION, ANIMATION_DURATION, drawStar)
end