import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"
import "levelManager"
import "constants"

local function drawGrid()
	for x = 1, TILES_PER_ROW do
		GFX.drawLine(x*TILE_SIZE, 0, x*TILE_SIZE, TILES_PER_COLUMN*TILE_SIZE)
	end
	for y = 1, TILES_PER_COLUMN do
		GFX.drawLine(0, y*TILE_SIZE, TILES_PER_ROW*TILE_SIZE, y*TILE_SIZE)
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
