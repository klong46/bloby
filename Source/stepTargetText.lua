import "constants"

class('StepTargetText').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-2x")
local SIZE = {WIDTH = 350, HEIGHT = 25}
local POSITION = {X = 235, Y = 180}

function StepTargetText:init(targetNum)
    StepTargetText.super.init(self)
    self.targetNum = targetNum
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(12)
    self:add()
end

function StepTargetText:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*3 stars = "..self.targetNum.." steps*", 0, 0)
end