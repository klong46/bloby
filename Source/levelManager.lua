import "CoreLibs/sprites"
import "level"
import "constants"

class('LevelManager').extends(SLIB)

function LevelManager:init(startingLevel)
    self.levelNum = startingLevel
    self.level = Level("1-"..self.levelNum)
    self:add()
end

function LevelManager:nextLevel()
    self:resetLevel()
end

function LevelManager:resetLevel()
    SLIB.removeAll()
    if self.levelNum > TOTAL_LEVELS then
        self.levelNum = TEST_LEVEL
    end
    self.level = Level("1-"..self.levelNum)
end