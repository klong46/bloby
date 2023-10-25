import "CoreLibs/sprites"
import "level"
import "constants"

class('LevelManager').extends(SLIB)

function LevelManager:init()
    self.levelNum = 1
    self.level = Level("1-"..self.levelNum)
    self:add()
end

function LevelManager:nextLevel()
    self.levelNum += 1
    self:resetLevel()
end

function LevelManager:resetLevel()
    SLIB.removeAll()
    if self.levelNum > TOTAL_LEVELS then
        self.levelNum = 1
    end
    self.level = Level("1-"..self.levelNum)
end
