import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"
import "levelManager"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

-- Global Variables
TileSize = 20
TilesPerRow = 20
TilesPerColumn = 12

local function drawGrid()
	for x = 1, TilesPerRow do
		GFX.drawLine(x*20, 0, x*20, TilesPerColumn*20)
	end
	for y = 1, TilesPerColumn do
		GFX.drawLine(0, y*20, TilesPerRow*20, y*20)
	end
end

GFX.setLineWidth(1)
local levelManager = LevelManager()

function PD.AButtonDown()
	levelManager:nextLevel()
end

function ResetLevel()
	levelManager:resetLevel()
end

function NextLevel()
	levelManager:nextLevel()
end

function PD.update()
	SLIB.update()
	drawGrid()
end
