import "constants"

class('CreditsBloby').extends(SLIB)

local downImg = GFX.image.new('img/credits/credits_bloby_down')
local upImg = GFX.image.new('img/credits/credits_bloby_up')

function CreditsBloby:init()
    CreditsBloby.super.init(self)
    self:setImage(downImg)
    self:moveTo(30, 30)
    self.startCrankPos = PD.getCrankPosition() - 30
    self:add()
end

function CreditsBloby:update()
    CreditsBloby.super.update(self)
    local crankChange = PD.getCrankChange()
    local yChange
    if crankChange ~= 0 then
        yChange = crankChange
    else
        yChange = CreditsScroll
    end
    if yChange > 0 then
        self:setImage(downImg)
    elseif yChange < 0 then
        self:setImage(upImg)
    end
    if (self.y + yChange) > 210 and yChange > 0 then
        yChange = 210 - self.y
    end
    if (self.y + yChange) < 30 and yChange < 0 then
        yChange = 30 - self.y
    end
    self:moveTo(self.x, self.y + yChange)
end