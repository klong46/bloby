import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"
import "levelManager"
import "constants"

local levelManager = LevelManager()

function PD.AButtonDown()
	NextLevel()
end

function PD.BButtonDown()
	ResetLevel()
end

function ResetLevel()
	levelManager:resetLevel()
end

function NextLevel()
	levelManager:nextLevel()
end

function PD.update()
	SLIB.update()
end
