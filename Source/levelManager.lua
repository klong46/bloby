import "CoreLibs/sprites"
import "level"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

local playerStartPositions = {
    PD.geometry.point.new(11, 5),
    PD.geometry.point.new(11, 1)
}
local ladderPositions = {
    PD.geometry.point.new(11, 12),
    PD.geometry.point.new(11, 12)
}

class('LevelManager').extends(SLIB)

function LevelManager:init()
    self.levelNum = 1
    self.level = Level(playerStartPositions[self.levelNum], ladderPositions[self.levelNum], "1-"..self.levelNum)
end

function LevelManager:nextLevel()
    SLIB.removeAll()
    self.levelNum += 1
    self.level = Level(playerStartPositions[self.levelNum], ladderPositions[self.levelNum], "1-"..self.levelNum)
end