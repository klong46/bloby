import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "level"
import "levelManager"
import "constants"
import "escapeTile"
import "stars"
import "escapeText"
import "movesText"
import "startButton"
import "levelSelectButton"
import "title"
import "menuManager"
import "levelSelect"

local levelManager
local menuManager = MenuManager()
local onMenu = true
local levelSelect
local moveForwardTimer
local moveBackTimer
LevelFinished = false
ReadyToContinue = false
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50

function StartGame()
    SLIB.removeAll()
    levelManager = LevelManager()
end

function GoToLevelSelect()
    SLIB.removeAll()
   levelSelect = LevelSelect()
end

function PD.leftButtonDown()
    if onMenu then
        menuManager:cursorLeft()
    elseif levelSelect then
        levelSelect:cursorLeft()
    end
end

function PD.upButtonDown()
    if levelSelect then
        levelSelect:cursorUp()
    end
end

function PD.downButtonDown()
    if levelSelect then
        levelSelect:cursorDown()
    end
end

function PD.rightButtonDown()
    if onMenu then
        menuManager:cursorRight()
    elseif levelSelect then
        levelSelect:cursorRight()
    end
end

local function moveForward()
    if not levelManager.level.player.isDead then
	    levelManager.level:moveForward()
    end
end

local function moveBack()
    if not levelManager.level.player.isDead then
	    levelManager.level:moveBack()
    end
end

local function removeForwardTimer()
    if moveForwardTimer then
        moveForwardTimer:remove()
    end
end

local function removeBackTimer()
    if moveBackTimer then
        moveBackTimer:remove()
    end
end

function PD.AButtonDown()
    if not LevelFinished and not onMenu then
        removeBackTimer()
        moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
        if PD.buttonIsPressed(playdate.kButtonLeft) then
            LevelOver()
        end
    elseif onMenu then
        menuManager:cursorSelect()
        onMenu = false
    elseif ReadyToContinue and not onMenu then
        ReadyToContinue = false
        LevelFinished = false
        levelManager:nextLevel()
    end
end

function PD.AButtonUp()
    if not onMenu then
        removeForwardTimer()
    end
end

function PD.BButtonDown()
    if not LevelFinished and not onMenu then
        removeForwardTimer()
        moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
    end
end

function PD.BButtonUp()
    if onMenu then
        removeBackTimer()
    end
end

function ResetLevel()
	levelManager:resetLevel()
end

function LevelOver()
    EscapeTile()
    LevelFinished = true
end

function ShowFinishScreen()
    Stars(3)
    EscapeText()
    MovesText(levelManager.level.turn-1 or 0)
end

function PD.update()
	PD.timer.updateTimers()
	SLIB.update()
end
