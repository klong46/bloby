import "constants"
import "continueButton"

class('MovesText').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-3x")
local smallFont = GFX.font.new("fonts/font-rains-2x")
local SIZE = {WIDTH = 200, HEIGHT = 22}
local POSITION = {X = 228, Y = 195}

function MovesText:init(moves)
    MovesText.super.init(self)
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(6)
    self.finished = false
    self.moveAnimator = GFX.animator.new(2500, 0, moves, playdate.easingFunctions.outCubic)
    self.continueButtonTimer = nil
    self:add()
end

local function showContinueButton()
    ContinueButton()
end

function MovesText:update()
    MovesText.super.update(self)
    if not self.finished then
        self:markDirty()
        if self.moveAnimator:ended() then
            self.continueButtonTimer = PD.timer.performAfterDelay(1500, showContinueButton)
            self.finished = true
        end
    end
end

function MovesText:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    GFX.setFont(smallFont, "bold")
    GFX.drawText("*moves: *", 0, 5)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*"..math.floor(self.moveAnimator:currentValue()).."*", 100, 0)
end