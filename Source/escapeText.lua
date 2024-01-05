import "CoreLibs/sprites"
import "constants"

local bigFont = GFX.font.new("fonts/font-rains-3x")

class('EscapeText').extends(SLIB)

function EscapeText:init()
    EscapeText.super.init(self)
    self:setSize(200, 100)
    self:moveTo(226, 85)
    self:setZIndex(6)
    self:add()
end

function EscapeText:draw()
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*Escape!*", 0, 0)
end