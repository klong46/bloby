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

function PD.AButtonDown()
    moveForwardTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveForward)
end

function PD.AButtonUp()
    if moveForwardTimer then
        moveForwardTimer:remove()
    end
end

function PD.BButtonDown()
    moveBackTimer = PD.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveBack)
end

function PD.BButtonUp()
    if moveBackTimer then
        moveBackTimer:remove()
    end
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
