import "CoreLibs/sprites"
import "constants"

class('MenuManager').extends(SLIB)

local currentLevel = 1

function MenuManager:init(startingLevel)
    MenuManager.super.init(self)
    currentLevel = startingLevel
    self.menuSelect = MenuSelect()
    self.menuBackground = MenuBackground()
    self.selectedBox = 1
    self:add()
end

function MenuManager:cursorUp()
    if self.selectedBox == 1 then
        self.selectedBox = 3
    else
        self.selectedBox -= 1
    end
    self.menuSelect:moveCursor(self.selectedBox)
    self.menuBackground:moveCursor(self.selectedBox)
end

function MenuManager:cursorDown()
    if self.selectedBox == 3 then
        self.selectedBox = 1
    else
        self.selectedBox += 1
    end
    self.menuSelect:moveCursor(self.selectedBox)
    self.menuBackground:moveCursor(self.selectedBox)
end

function MenuManager:cursorSelect()
    if self.selectedBox == 1 then
        if currentLevel == 1 then
            Tutorial = ControlScreen()
        else
            StartGame(currentLevel)
        end
        
    elseif self.selectedBox == 2 then
        GoToLevelSelect()
    else
        GoToLevelSelect() -- gonna add credits here
    end
    self:remove()
end