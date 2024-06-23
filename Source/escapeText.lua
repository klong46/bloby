import "constants"

class('EscapeText').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-3x")
local POSITION = {X = 226, Y = 85}
local SIZE = {WIDTH = 200, HEIGHT = 100}

function EscapeText:init()
    EscapeText.super.init(self)
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(6)
    self:add()
end

function EscapeText:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*Escape!*", 0, 0)
end