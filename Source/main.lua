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

-- bugs: 
-- player can't turn on second reverse



-- local function resetSaveData()
--     local gameData = {
--         currentLevel = 1,
--         scores = {}
--     }
--     PD.datastore.write(gameData)
-- end

-- resetSaveData()

local gameData = {}
local startingLevel = 1
local levelManager
local starScores = {}
gameData = PD.datastore.read()
if gameData then
    startingLevel = gameData.currentLevel
    if gameData.scores then
        starScores = gameData.scores
    end
end

local function saveGameData()
    gameData = {
        currentLevel = levelManager.levelNum,
        scores = levelManager.scores
    }
    PD.datastore.write(gameData)
end

function PD.gameWillTerminate()
    saveGameData()
end

function PD.gameWillSleep()
    saveGameData()
end

local menuManager
local onMenu = true
local levelSelect
local moveForwardTimer
local moveBackTimer
LevelFinished = false
ReadyToContinue = false
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50
local pdMenu = PD.getSystemMenu()

local function initMenu()
    LevelFinished = false
    ReadyToContinue = false
    menuManager = MenuManager(startingLevel)
    onMenu = true
end

initMenu()

local function returnToMenu()
    SLIB.removeAll()
    initMenu()
    pdMenu:removeAllMenuItems()
end

function StartGame(levelNum)
    SLIB.removeAll()
    levelManager = LevelManager(levelNum, starScores)
end

function GoToLevelSelect()
    SLIB.removeAll()
    levelSelect = LevelSelect(startingLevel, starScores)
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
    if onMenu then
        menuManager:cursorSelect()
        onMenu = false
        pdMenu:addMenuItem("Main Menu", returnToMenu)
        pdMenu:addMenuItem("Restart Level", function ()
            levelManager:resetLevel()
        end)
    else
        if levelSelect then
            levelSelect:select()
            levelSelect = nil
        elseif not LevelFinished then
            removeBackTimer()
            moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
            -- if PD.buttonIsPressed(PD.kButtonLeft) then
            --     ReadyToContinue = false
            --     LevelFinished = false
            --     levelManager.levelNum += 1
            --     levelManager:nextLevel()
            -- end
        elseif ReadyToContinue then
            ReadyToContinue = false
            LevelFinished = false
            levelManager:nextLevel()
        end
    end
end

function PD.AButtonUp()
    if not onMenu then
        removeForwardTimer()
    end
end

function PD.BButtonDown()
    if not LevelFinished and not (onMenu or levelSelect) then
        removeForwardTimer()
        moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
    elseif levelSelect then
        returnToMenu()
    end
end



function PD.BButtonUp()
    if not onMenu then
        removeBackTimer()
    end
end

function ResetLevel()
	levelManager:resetLevel()
end

function LevelOver(stars)
    levelManager.levelNum += 1
    table.insert(levelManager.scores, stars)
    EscapeTile(stars)
    LevelFinished = true
end

function ShowFinishScreen(stars)
    Stars(stars)
    EscapeText()
    MovesText(levelManager.level.turn-1 or 0)
end

function PD.update()
	PD.timer.updateTimers()
	SLIB.update()
end
