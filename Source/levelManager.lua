import "CoreLibs/sprites"
import "level"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

local playerStartPositions = {
    PD.geometry.point.new(11, 1),
    PD.geometry.point.new(11, 1)
}
local ladderPositions = {
    PD.geometry.point.new(11, 12),
    PD.geometry.point.new(11, 12)
}

class('LevelManager').extends(SLIB)

function LevelManager:init()
    self.levelNum = 1
    print(playerStartPositions[levelNum])
    self.level = Level(PD.geometry.point.new(11, 1), PD.geometry.point.new(11, 12), "1-1")
end

function LevelManager:nextLevel()
    self.levelNum += 1
    SLIB.removeAll()
    self.level = Level(PD.geometry.point.new(11, 1), PD.geometry.point.new(11, 12), "testLevel")
end