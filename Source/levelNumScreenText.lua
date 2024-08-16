import "constants"
import "stepTargetText"

class('LevelNumScreenText').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-3x")
local SIZE = {WIDTH = 200, HEIGHT = 25}
local POSITION = {X = 200, Y = 125}

function LevelNumScreenText:init(levelNum, targetNum)
    LevelNumScreenText.super.init(self)
    self.targetText = StepTargetText(targetNum)
    self.levelNum = levelNum
    if levelNum > 9 then
        POSITION.X = 180
    end
    self.dismissed = false
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(12)
    self:add()
end

function LevelNumScreenText:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    GFX.setFont(bigFont, "bold")
    GFX.drawText("*"..self.levelNum.."*", 100, 0)
end

function LevelNumScreenText:update()
    LevelNumScreenText.super.update(self)
    if self.dismissed then
        self.targetText:remove()
        self:remove()
    end
end