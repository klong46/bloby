import "CoreLibs/sprites"
import "constants"

local bigFont = GFX.font.new("fonts/font-rains-3x")
local smallFont = GFX.font.new("fonts/font-rains-2x")

class('MovesText').extends(SLIB)

function MovesText:init(moves)
    MovesText.super.init(self)
    self:setSize(200, 100)
    self:moveTo(235, 225)
    self:setZIndex(100)
    self.moves = moves
    self:add()
end

function MovesText:draw()
	GFX.pushContext()
    GFX.setFont(smallFont, "bold")
    GFX.drawText("*moves: *", 0, 5)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*"..self.moves.."*", 100, 0)
	GFX.popContext()
end