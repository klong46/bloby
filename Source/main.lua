import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"

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
local levelOnePlayerStartPosition = PD.geometry.point.new(11, 1)
local levelOneLadderPosition = PD.geometry.point.new(11, 12)
local level = Level(levelOnePlayerStartPosition, levelOneLadderPosition)

function PD.update()
	SLIB.update()
	drawGrid()
end
