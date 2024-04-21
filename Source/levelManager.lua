import "CoreLibs/sprites"
import "level"
import "constants"

class('LevelManager').extends(SLIB)

function LevelManager:init(startingLevel)
    self.levelNum = startingLevel
    self.level = Level(self.levelNum)
    self:add()
end

function LevelManager:resetLevel()
    SLIB.removeAll()
    if self.levelNum > TOTAL_LEVELS then
        self.levelNum = TEST_LEVEL
    end
    self.level = Level(self.levelNum)
    LevelFinished = false
end