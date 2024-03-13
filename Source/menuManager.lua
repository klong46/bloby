import "CoreLibs/sprites"
import "constants"

class('MenuManager').extends(SLIB)

local currentLevel = 1

function MenuManager:init(startingLevel)
    MenuManager.super.init(self)
    currentLevel = startingLevel
    self.startButton = StartButton()
    self.levelSelectButton = LevelSelectButton()
    self.title = Title()
    self.selectedBox = 1
    self:add()
end

function MenuManager:cursorLeft()
    self.selectedBox = 1
    self.startButton:highlight()
    self.levelSelectButton:unhighlight()
end

function MenuManager:cursorRight()
    self.selectedBox = 2
    self.levelSelectButton:highlight()
    self.startButton:unhighlight()
end

function MenuManager:cursorSelect()
    if self.selectedBox == 1 then
        StartGame(currentLevel)
    else
        GoToLevelSelect()
    end
    self:remove()
end