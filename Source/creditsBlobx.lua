import "constants"

class('CreditsBlobx').extends(SLIB)

local downImg = GFX.image.new('img/credits/credits_blobx_down')
local upImg = GFX.image.new('img/credits/credits_blobx_up')


function CreditsBlobx:init()
    CreditsBlobx.super.init(self)
    self:setImage(downImg)
    self:moveTo(370, 210)
    self.startCrankPos = PD.getCrankPosition() - 30
    self:add()
end

function CreditsBlobx:update()
    CreditsBlobx.super.update(self)
    local crankChange = PD.getCrankChange() * -1
    if crankChange > 0 then
        self:setImage(downImg)
    elseif crankChange < 0 then
        self:setImage(upImg)
    end
    local yChange = crankChange

    if (self.y + crankChange) > 210 and crankChange > 0 then
        yChange = 210 - self.y
    end
    if (self.y + crankChange) < 30 and crankChange < 0 then
        yChange = 30 - self.y
    end
    self:moveTo(self.x, self.y + yChange)
end