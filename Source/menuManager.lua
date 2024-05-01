import "CoreLibs/sprites"
import "constants"

class('MenuManager').extends(SLIB)

local currentLevel = 1
local numScores = 0

function MenuManager:init(startingLevel, scores)
    MenuManager.super.init(self)
    numScores = scores
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
        if currentLevel == 1 and numScores == 0 then
            Tutorial = ControlScreen()
        else
            StartGame(currentLevel)
        end
    elseif self.selectedBox == 2 then
        GoToLevelSelect()
    else
        GoToCredits()
    end
    self:remove()
end

function MenuManager:update()
    MenuManager.super.update(self)
    if CrankTicks > 0 then
        self:cursorDown()
    elseif CrankTicks < 0 then
        self:cursorUp()
    end
end