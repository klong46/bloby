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

-- final level: put boxes and blobxs in correct spot (box in corner forming and picture, blobxs 
-- paralyzed by lasers to unlock finish)

local function resetSaveData()
    local gameData = {
        currentLevel = 1,
        scores = {}
    }
    PD.datastore.write(gameData)
end

-- resetSaveData()

local gameData = {}
local startingLevel = 1
local levelManager
local movesText
local highestLevel = 1
local starScores = {}
local bonusLevelUnlocked = false
local levelFinishedStars
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
        currentLevel = levelManager.levelNum,
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
    menuManager = MenuManager(startingLevel)
    onMenu = true
end

initMenu()

function ReturnToMenu()
    SLIB.removeAll()
    if movesText and movesText.continueButtonTimer then
        movesText.continueButtonTimer:remove()
    end
    if levelFinishedStars then
        if levelFinishedStars.starAppearTimer then
            levelFinishedStars.starAppearTimer:remove()
        end
        if levelFinishedStars.starTimer then
            levelFinishedStars.starTimer:remove()
        end
    end
    initMenu()
    pdMenu:removeAllMenuItems()
end

function StartGame(levelNum)
    SLIB.removeAll()
    levelManager = LevelManager(levelNum, starScores)
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", ReturnToMenu)
    RestartMenuItem = pdMenu:addMenuItem("restart", function ()
        levelManager:resetLevel()
    end)
    pdMenu:addMenuItem("next level", function ()
        ReadyToContinue = false
        LevelFinished = false
        levelManager.levelNum += 1
        levelManager:nextLevel()
    end)
end


-- DEVELOPMENT: goes straight to TEST_LEVEL
-- StartGame(TEST_LEVEL)
-- onMenu = false

function GoToLevelSelect()
    SLIB.removeAll()
    levelSelect = LevelSelect(highestLevel, starScores)
    for i = 1, levelManager.levelNum-1, 1 do
        levelSelect:cursorRight()
    end
    pdMenu:addMenuItem("menu", ReturnToMenu)
end

function PD.leftButtonDown()
    if levelSelect then
        levelSelect:cursorLeft()
    end
end

function PD.upButtonDown()
    if onMenu then
        menuManager:cursorUp()
    elseif levelSelect then
        levelSelect:cursorUp()
    end
end

function PD.downButtonDown()
    if onMenu then
        menuManager:cursorDown()
    elseif levelSelect then
        levelSelect:cursorDown()
    end
end

function PD.rightButtonDown()
    if levelSelect then
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
                levelManager:nextLevel()
                RestartMenuItem = pdMenu:addMenuItem("restart", function ()
                    levelManager:resetLevel()
                end)
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
        scrollTimer:remove()
        ReadyToContinue = false
        LevelFinished = false
    end
end

function LevelOver(stars)
    if allStarsEarned() and not bonusLevelUnlocked then
        bonusLevelUnlocked = true
        GoToLevelSelect()
        local scrollTimer
        scrollTimer = PD.timer.keyRepeatTimerWithDelay(
            30,
            30,
            function ()
                levelSelectCursorDown(scrollTimer)
            end)
    end
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", ReturnToMenu)
    pdMenu:addMenuItem("next level", function ()
        ReadyToContinue = false
        LevelFinished = false
        levelManager.levelNum += 1
        levelManager:nextLevel()
    end)
    if #starScores >= levelManager.levelNum then
        if starScores[levelManager.levelNum] < stars then
            starScores[levelManager.levelNum] = stars
        end
    else
        table.insert(starScores, stars)
    end
    levelManager.levelNum += 1
    if levelManager.levelNum > highestLevel then
        highestLevel = levelManager.levelNum
    end
    if levelManager.levelNum > startingLevel then
        startingLevel = levelManager.levelNum
    end
end

function ShowFinishScreen(stars)
    levelFinishedStars = Stars(stars)
    EscapeText()
    movesText = MovesText(levelManager.level.turn-1 or 0)
end

function PD.update()
	PD.timer.updateTimers()
	SLIB.update()
end
