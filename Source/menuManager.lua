import "CoreLibs/sprites"
import "constants"
import "transition"

class('MenuManager').extends(SLIB)

local currentLevel = 1
local numScores = 0

local blipSound = playdate.sound.sampleplayer.new('snd/blip_select')


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
    blipSound:play()
    if self.selectedBox == 1 then
        self.selectedBox = 3
    else
        self.selectedBox -= 1
    end
    self.menuSelect:moveCursor(self.selectedBox)
    self.menuBackground:moveCursor(self.selectedBox)
end

function MenuManager:cursorDown()
    blipSound:play()
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
            Transition("tutorial")
        else
            Transition("start_game", currentLevel)
        end
    elseif self.selectedBox == 2 then
        Transition("level_select")
    else
        Transition("credits")
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