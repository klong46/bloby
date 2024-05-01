import "constants"

class('CreditsText').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-3x")

function CreditsText:init()
    CreditsText.super.init(self)
    self:setSize(250, 100)
    self:moveTo(225, 85)
    self:setZIndex(6)
    self:add()
end

function CreditsText:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*Kyle Long*", 0, 0)
end