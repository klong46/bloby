import "CoreLibs/sprites"
import "constants"

class('MenuManager').extends(SLIB)

function MenuManager:init()
    MenuManager.super.init(self)
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
        StartGame()
    else
        LevelSelect()
    end
end