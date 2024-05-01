import "constants"

class('LevelSelectNumber').extends(SLIB)

local bigFont = GFX.font.new("fonts/font-rains-3x")
local smallFont = GFX.font.new("fonts/font-rains-2x")
local WIDTH = 80
local DOUBLE_DIGITS = 10
local SIZE = {WIDTH = 220, HEIGHT = 20}

function LevelSelectNumber:init(x, y, levelNum, selected)
    LevelSelectNumber.super.init(self)
    self.levelNum = levelNum
    self.xOffset = 37
    self.yOffset = 55
    if levelNum >= DOUBLE_DIGITS then
        self.xOffset = 45
    end
    if selected then
        self.xOffset += 2
    end
    self.selected = selected
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    self:moveTo(x*WIDTH-self.xOffset, y*WIDTH-self.yOffset)
    self:add()
end

function LevelSelectNumber:draw()
    GFX.setImageDrawMode(GFX.kDrawModeCopy)
    local label = math.floor( self.levelNum )
    GFX.setFont(smallFont, "bold")
    if self.selected then
        GFX.setFont(bigFont, "bold")
    end
    GFX.drawText("*"..label.."*", 100, 0)
end

function LevelSelectNumber:select()
    local x = self.x
    if self.levelNum >= DOUBLE_DIGITS then
        x -= 8
    end
    self:moveTo(x, self.y)
    self.selected = true
end

function LevelSelectNumber:unselect()
    local x = self.x
    if self.levelNum >= DOUBLE_DIGITS then
        x += 8
    end
    self:moveTo(x, self.y)
    self.selected = false
end