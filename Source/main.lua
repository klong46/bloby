import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "level"
import "levelManager"
import "constants"

local levelManager = LevelManager()
local moveForwardTimer = nil
local moveBackTimer = nil
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50

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
    removeBackTimer()
    moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
    if PD.buttonIsPressed(playdate.kButtonLeft) then
        NextLevel()
    end
end

function PD.AButtonUp()
    removeForwardTimer()
end

function PD.BButtonDown()
    removeForwardTimer()
    moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
end

function PD.BButtonUp()
    removeBackTimer()
end

function ResetLevel()
	levelManager:resetLevel()
end

function NextLevel()
	levelManager:nextLevel()
end

function PD.update()
	PD.timer.updateTimers()
	SLIB.update()
end
