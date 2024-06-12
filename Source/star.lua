import "staticObject"
import "constants"

local STAR_DISTANCE = 110
local ANIMATOR_DURATION = 1000

class('Star').extends(SLIB)

local image = GFX.image.new('img/star')
local starSound = playdate.sound.sampleplayer.new('snd/star_hit')


function Star:init(order)
    Star.super.init(self)
    self:moveTo(self:getPosition(order))
    self:setImage(image)
    self:setZIndex(6)
    starSound:play()

    self:add()
    self.rotationAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 360, playdate.easingFunctions.outExpo)
    self.scaleAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 1, playdate.easingFunctions.outExpo)
end

function Star:getPosition(order)
    local pos = PD.geometry.point.new(100, 120)
    if order == 2 then
        pos.x += STAR_DISTANCE
    elseif order == 3 then
        pos.x += STAR_DISTANCE * 2
    end
    return pos
end

function Star:update()
    self:setScale(self.scaleAnimator:currentValue())
    self:setRotation(self.rotationAnimator:currentValue())
end