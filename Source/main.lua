import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/crank"
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
import "creditsText"
import "transition"
import "levelNumScreen"
import "logo"

local menuMusic = PD.sound.fileplayer.new('snd/opening')
menuMusic:setVolume(0.7)
ThemeMusic = PD.sound.fileplayer.new('snd/bytf')
BossMusic = PD.sound.fileplayer.new('snd/bytf-fast')
local blipSound = playdate.sound.sampleplayer.new('snd/blip_select')

-- INSTANCE VARS
local gameData = {}
local startingLevel = 1
local levelManager
local highestLevel = 1
local starScores = {}
local bonusLevelAnimationPlayed = false
local playBonusLevelAnimation = false
local gameWinScreen
local credits
local menuManager
local onMenu = true
local levelSelect
local moveForwardTimer
local moveBackTimer
LevelFinished = false
ReadyToContinue = false
OnControlScreen = false
Tutorial = nil
InTransition = true
ReadingPanel = false
CreditsScroll = 0
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50
local pdMenu = PD.getSystemMenu()
CrankTicks = 0
Turn = 0

-- LOAD SAVE DATA
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
    if gameData.bonusLevelAnimationPlayed then
        bonusLevelAnimationPlayed = gameData.bonusLevelAnimationPlayed
    end
end

local function saveGameData()
    gameData = {
        currentLevel = startingLevel,
        highestUnlockedLevel = highestLevel,
        scores = starScores,
        bonusLevelAnimationPlayed = bonusLevelAnimationPlayed
    }
    PD.datastore.write(gameData)
end

function PD.gameWillTerminate()
    saveGameData()
end

function PD.deviceWillSleep()
    saveGameData()
end


-- MUSIC FUNCTIONS
function StartThemeMusic(levelNum)
    menuMusic:stop()
    if levelNum == BONUS_LEVEL then
        BossMusic:setVolume(1)
        BossMusic:play(0)
    else
        ThemeMusic:setVolume(1)
        ThemeMusic:play(0)
    end
    
end

-- MENU FUNCTIONS:
local function initMenu()
    ThemeMusic:stop()
    BossMusic:stop()
    menuMusic:play()
    LevelFinished = false
    ReadyToContinue = false
    menuManager = MenuManager(startingLevel, #starScores)
    onMenu = true
end


Logo()
initMenu()

function ReturnToMenu()
    for i, timer in ipairs(PD.timer.allTimers()) do
        timer:remove()
    end
    initMenu()
    pdMenu:removeAllMenuItems()
end

function StartGame(levelNum)
    startingLevel = levelNum
    levelManager = LevelManager(levelNum, starScores)
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", function() Transition("menu") end)
    RestartMenuItem = pdMenu:addMenuItem("restart", function()
        levelManager:resetLevel()
    end)
    pdMenu:addMenuItem("next level",
        function()
            levelManager.level:checkPlayerWin(true)
            levelManager.level.levelNumScreen.text:remove()
            levelManager.level.levelNumScreen.text.targetText:remove()
            levelManager.level.levelNumScreen:remove()
        end
    )
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

function GoToLevelSelect()
    levelSelect = LevelSelect(highestLevel, starScores)
    for i = 1, startingLevel - 1, 1 do
        levelSelect:cursorRight()
    end
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", function() Transition("menu") end)
    if playBonusLevelAnimation then
        PD.timer.keyRepeatTimerWithDelay(20,20, levelSelectCursorDown)
        playBonusLevelAnimation = false
    end
end

function GoToCredits()
    credits = CreditsText()
    pdMenu:addMenuItem("menu", function() Transition("menu") end)
end

-- UPDATE FUNCTIONS:
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
    if #starScores ~= TOTAL_LEVELS then return false end
    for i, score in ipairs(starScores) do
        if score ~= 3 then
            return false
        end
    end
    return true
end

function ResetLevel()
    levelManager:resetLevel()
end

function StartTutorial()
    Tutorial = ControlScreen()
end

function LevelOver(stars)
    pdMenu:removeAllMenuItems()
    pdMenu:addMenuItem("menu", function() Transition("menu") end)
    RestartMenuItem = pdMenu:addMenuItem("restart", function()
        levelManager:resetLevel()
        for i, timer in ipairs(PD.timer.allTimers()) do
            timer:remove()
        end
    end)
    pdMenu:addMenuItem("next level",
        function()
            levelManager.level:checkPlayerWin(true)
            levelManager.level.levelNumScreen.text:remove()
            levelManager.level.levelNumScreen.text.targetText:remove()
            levelManager.level.levelNumScreen:remove()
        end
    )
    if #starScores >= levelManager.levelNum then
        if starScores[levelManager.levelNum] < stars then
            starScores[levelManager.levelNum] = stars
        end
    else
        table.insert(starScores, stars)
    end
    if levelManager.levelNum < TOTAL_LEVELS then
        startingLevel = levelManager.levelNum + 1
        if levelManager.levelNum + 1 > highestLevel then
            highestLevel = levelManager.levelNum + 1
        end
    end
    if allStarsEarned() then
        highestLevel = BONUS_LEVEL
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
    if levelSelect or onMenu then
        CrankTicks = PD.getCrankTicks(LEVEL_SELECT_CRANK_SPEED)
    else
        CrankTicks = PD.getCrankTicks(MOVE_CRANK_SPEED)
    end
end

-- BUTTON INPUT:
function PD.leftButtonDown()
    if not InTransition then
        if levelSelect then
            levelSelect:cursorLeft()
        elseif gameWinScreen and not gameWinScreen.closed then
            gameWinScreen:left()
        elseif not LevelFinished and not credits and not onMenu and levelManager.level.player.isBlocked then
            local player = levelManager.level.player
            player:setDirectionImage(DIRECTIONS.LEFT)
            player.direction = DIRECTIONS.LEFT
            player:checkPanel()
        end
    end
end

function PD.upButtonDown()
    if not InTransition then
        if onMenu then
            menuManager:cursorUp()
        elseif levelSelect then
            levelSelect:cursorUp()
        elseif gameWinScreen and not gameWinScreen.closed then
            gameWinScreen:up()
        elseif not LevelFinished and not credits and levelManager.level.player.isBlocked then
            local player = levelManager.level.player
            player:setDirectionImage(DIRECTIONS.UP)
            player.direction = DIRECTIONS.UP
            player:checkPanel()
        end
        if credits then
            CreditsScroll = -5
        end
    end
end

function PD.downButtonDown()
    if not InTransition then
        if onMenu then
            menuManager:cursorDown()
        elseif levelSelect then
            levelSelect:cursorDown()
        elseif gameWinScreen and not gameWinScreen.closed then
            gameWinScreen:down()
        elseif not LevelFinished and not credits and levelManager.level.player.isBlocked then
            local player = levelManager.level.player
            player:setDirectionImage(DIRECTIONS.DOWN)
            player.direction = DIRECTIONS.DOWN
            player:checkPanel()
        end
        if credits then
            CreditsScroll = 5
        end
    end
end

function PD.downButtonUp()
    if not InTransition and credits then
        CreditsScroll = 0
    end
end

function PD.upButtonUp()
    if not InTransition and credits then
        CreditsScroll = 0
    end
end

function PD.rightButtonDown()
    if not InTransition then
        if levelSelect then
            levelSelect:cursorRight()
        elseif gameWinScreen and not gameWinScreen.closed then
            gameWinScreen:right()
        elseif not LevelFinished and not credits and not onMenu and levelManager.level.player.isBlocked then
            local player = levelManager.level.player
            player:setDirectionImage(DIRECTIONS.RIGHT)
            player.direction = DIRECTIONS.RIGHT
            player:checkPanel()
        end
    end
end

function PD.AButtonDown()
    if not InTransition then
        if onMenu then
            blipSound:play()
            menuManager:cursorSelect()
            onMenu = false
        elseif OnControlScreen and Tutorial then
            blipSound:play()
            Tutorial:next()
        elseif levelSelect then
            blipSound:play()
            levelSelect:select()
            levelSelect = nil
        elseif not LevelFinished and not credits then
            RemoveBackTimer()
            moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
        elseif ReadyToContinue then
            blipSound:play()
            ReadyToContinue = false
            LevelFinished = false
            if not bonusLevelAnimationPlayed and allStarsEarned() then
                bonusLevelAnimationPlayed = true
                playBonusLevelAnimation = true
                Transition("level_select")
            elseif levelManager.levelNum == BONUS_LEVEL then
                SLIB:removeAll()
                pdMenu:removeAllMenuItems()
                pdMenu:addMenuItem("menu",
                    function()
                        Transition("menu")
                        gameWinScreen.menuMusic:stop()
                        gameWinScreen = nil
                    end
                )
                gameWinScreen = GameWinScreen()
            elseif levelManager.levelNum == TOTAL_LEVELS then
                Transition("menu")
            else
                levelManager.levelNum += 1
                levelManager:resetLevel()
            end
        end
    end
end

function PD.AButtonUp()
    if not InTransition then
        if not onMenu then
            RemoveForwardTimer()
        end
    end
end

function PD.BButtonDown()
    if not InTransition then
        if not LevelFinished and not (onMenu or levelSelect or OnControlScreen or credits) then
            RemoveForwardTimer()
            moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
        elseif levelSelect or credits then
            blipSound:play()
            Transition("menu")
            levelSelect = nil
            credits = nil
        elseif OnControlScreen and Tutorial then
            blipSound:play()
            Tutorial:back()
        end
    end
end

function PD.BButtonUp()
    if not InTransition then
        if not onMenu then
            RemoveBackTimer()
        end
    end
end
