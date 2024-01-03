import "CoreLibs/sprites"
import "staticObject"
import "constants"

local STAR_DISTANCE = 85
local ANIMATOR_DURATION = 1000

class('Star').extends(SLIB)

local image = GFX.image.new('img/star')

function Star:init(order)
    Star.super.init(self)
    self:moveTo(self:getPosition(order))
    self:setImage(image)
    self:setZIndex(6)
    self:add()
    self.rotationAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 360, playdate.easingFunctions.outCubic)
    self.scaleAnimator = GFX.animator.new(ANIMATOR_DURATION, 0, 1, playdate.easingFunctions.outCubic)
end

function Star:getPosition(order)
    local pos = PD.geometry.point.new(115, 120)
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