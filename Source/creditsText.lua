import "constants"
import "creditsBloby"
import "creditsBlobx"

class('CreditsText').extends(SLIB)

local SCROLL_CONVERSION = -1.6
local image = GFX.image.new('img/credits/credits')

function CreditsText:init()
    CreditsText.super.init(self)
    self:setImage(image)
    self:moveTo(205, 263)
    CreditsBloby()
    CreditsBlobx()
    self:add()
end

function CreditsText:update()
    CreditsText.super.update(self)
    local crankChange = (PD.getCrankChange()/2) * SCROLL_CONVERSION
    local yChange
    if crankChange ~= 0 then
        yChange = crankChange
    else
        yChange = CreditsScroll * SCROLL_CONVERSION
    end
        if (self.y + yChange) > 263 and yChange > 0 then
            yChange = 263 - self.y
        end
        if (self.y + yChange) < -30 and yChange < 0 then
            yChange = -30 - self.y
        end
        self:moveTo(self.x, self.y + yChange)
end