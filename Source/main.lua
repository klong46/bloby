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
import "menuSelect"
import "menuManager"
import "levelSelect"
import "menuBackground"
import "controlScreen"
import "gameWinScreen"

local function resetSaveData()
    local gameData = {
        currentLevel = 1,
        scores = {},
        startingLevel = 1,
        highestUnlockedLevel = 1,
        bonusLevelUnlocked = false
    }
    PD.datastore.write(gameData)
end

-- resetSaveData()

local gameData = {}
local startingLevel = 1
local levelManager
local highestLevel = 1
local starScores = {}
local bonusLevelUnlocked = false
local gameWinScreen
CrankTicks = 0
gameData = PD.datastore.read()
if gameData then
    if gameData.currentLevel then
        startingLevel = gameData.currentLevel
    end
    if gameData.highestUnlockedLevel then
        highestLevel = gameData.highestUnlockedLevel
    end
    if gameData.scores then
        starScores = gameData.scores
    end
    if gameData.bonusLevelUnlocked then
        bonusLevelUnlocked = gameData.bonusLevelUnlocked
    end
end

local function saveGameData()
    gameData = {
        currentLevel = startingLevel,
        highestUnlockedLevel = highestLevel,
        scores = starScores,
        bonusLevelUnlocked = bonusLevelUnlocked
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
OnControlScreen = false
Tutorial = nil
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50
local pdMenu = PD.getSystemMenu()

local function initMenu()
    LevelFinished = false
    ReadyToContinue = false
    menuManager = MenuManager(startingLevel, #starScores)
    onMenu = true
end

initMenu()

function ReturnToMenu()
    SLIB.removeAll()
    for i, timer in ipairs(PD.timer.allTimers()) do
        timer:remove()
    end
    initMenu()
    pdMenu:removeAllMenuItems()
end

function StartGame(levelNum)
    SLIB.removeAll()
    startingLevel = levelNum
    levelManager = LevelManager(levelNum, starScores)
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", ReturnToMenu)
    RestartMenuItem = pdMenu:addMenuItem("restart", function()
        levelManager:resetLevel()
    end)
end

-- DEVELOPMENT: goes straight to TEST_LEVEL
-- StartGame(TEST_LEVEL)
-- onMenu = false
-- starScores = {}
-- for i = 1, 30, 1 do
--     table.insert(starScores, 3)
-- end
-- starScores[30] = 1

function GoToLevelSelect()
    SLIB.removeAll()
    levelSelect = LevelSelect(highestLevel, starScores)
    for i = 1, startingLevel - 1, 1 do
        levelSelect:cursorRight()
    end
    pdMenu:addMenuItem("menu", ReturnToMenu)
end

function PD.leftButtonDown()
    if levelSelect then
        levelSelect:cursorLeft()
    end
    if gameWinScreen and not gameWinScreen.closed then
        gameWinScreen:left()
    end
end

function PD.upButtonDown()
    if onMenu then
        menuManager:cursorUp()
    elseif levelSelect then
        levelSelect:cursorUp()
    end
    if gameWinScreen and not gameWinScreen.closed then
        gameWinScreen:up()
    end
end

function PD.downButtonDown()
    if onMenu then
        menuManager:cursorDown()
    elseif levelSelect then
        levelSelect:cursorDown()
    end
    if gameWinScreen and not gameWinScreen.closed then
        gameWinScreen:down()
    end
end

function PD.rightButtonDown()
    if levelSelect then
        levelSelect:cursorRight()
    end
    if gameWinScreen and not gameWinScreen.closed then
        gameWinScreen:right()
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

function RemoveForwardTimer()
    if moveForwardTimer then
        moveForwardTimer:remove()
    end
end

function RemoveBackTimer()
    if moveBackTimer then
        moveBackTimer:remove()
    end
end

local function allStarsEarned()
    if #starScores ~= (TOTAL_LEVELS - 1) then return false end
    for i, score in ipairs(starScores) do
        if score ~= 3 then
            return false
        end
    end
    return true
end

local function levelSelectCursorDown(scrollTimer)
    levelSelect:cursorRight()
    if levelSelect.cursorPos.y == 7 and levelSelect.cursorPos.x == 1 then
        if scrollTimer then
            scrollTimer:remove()
        end
        ReadyToContinue = false
        LevelFinished = false
    end
end

function PD.AButtonDown()
    if onMenu then
        menuManager:cursorSelect()
        onMenu = false
    else
        if OnControlScreen and Tutorial then
            Tutorial:next()
        else
            if levelSelect then
                levelSelect:select()
                levelSelect = nil
            elseif not LevelFinished then
                RemoveBackTimer()
                moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
            elseif ReadyToContinue then
                ReadyToContinue = false
                LevelFinished = false
                if (not bonusLevelUnlocked) and allStarsEarned() then
                    bonusLevelUnlocked = true
                    highestLevel = BONUS_LEVEL
                    GoToLevelSelect()
                    PD.timer.keyRepeatTimerWithDelay(30,30, levelSelectCursorDown)
                else
                    if levelManager.levelNum == BONUS_LEVEL then
                        SLIB:removeAll()
                        gameWinScreen = GameWinScreen()
                    else
                        if levelManager.levelNum == (TOTAL_LEVELS - 1) then
                            ReturnToMenu()
                        else
                            levelManager.levelNum += 1
                            levelManager:resetLevel()
                        end
                    end
                end
            end
        end
    end
end

function PD.AButtonUp()
    if not onMenu then
        RemoveForwardTimer()
    end
end

function PD.BButtonDown()
    if not LevelFinished and not (onMenu or levelSelect or OnControlScreen) then
        RemoveForwardTimer()
        moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
    elseif levelSelect then
        ReturnToMenu()
        levelSelect = nil
    elseif OnControlScreen and Tutorial then
        Tutorial:back()
    end
end

function PD.BButtonUp()
    if not onMenu then
        RemoveBackTimer()
    end
end

function ResetLevel()
    levelManager:resetLevel()
end

function LevelOver(stars)
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", ReturnToMenu)
    RestartMenuItem = pdMenu:addMenuItem("restart", function()
        levelManager:resetLevel()
        for i, timer in ipairs(PD.timer.allTimers()) do
            timer:remove()
        end
    end)
    if #starScores >= levelManager.levelNum then
        if starScores[levelManager.levelNum] < stars then
            starScores[levelManager.levelNum] = stars
        end
    else
        table.insert(starScores, stars)
    end
    if levelManager.levelNum ~= BONUS_LEVEL then
        startingLevel = levelManager.levelNum + 1
        if levelManager.levelNum + 1 > highestLevel then
            highestLevel = levelManager.levelNum + 1
        end
    end
end

function ShowFinishScreen(stars)
    Stars(stars)
    EscapeText()
    MovesText(Turn - 1 or 0)
end

function PD.update()
    PD.timer.updateTimers()
    SLIB.update()
    CrankTicks = PD.getCrankTicks(CRANK_SPEED)
end
