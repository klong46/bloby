import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite


-- Global Variables
TileSize = 20

local tilesPerRow = 20
local tilesPerColumn = 12

local grid = {1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1}

local function drawWall(x, y)
	GFX.fillRect(x*TileSize, y*TileSize, TileSize, TileSize)
end

-- local function drawLaserBase(x, y)
-- 	GFX.setLineWidth(2)
-- 	GFX.drawRect(x*TileSize, y*TileSize, 20, 20)
-- 	GFX.drawRect(x*TileSize+5, y*TileSize+5, 10, 10)
-- end

-- local function drawLaser(x, y)
-- 	GFX.setLineWidth(4)
-- 	GFX.setLineCapStyle(GFX.kLineCapStyleRound)
-- 	GFX.drawLine(x*TileSize+10, y*TileSize+10, 13*TileSize-2, y*TileSize+10)
-- end

local function drawGrid()
	GFX.setLineWidth(1)

	for x = 1, tilesPerRow do
		GFX.drawLine(x*20, 0, x*20, tilesPerColumn*20)
	end

	for y = 1, tilesPerColumn do
		GFX.drawLine(0, y*20, tilesPerRow*20, y*20)
	end

	for x = 0, tilesPerRow-1 do
		for y = 0, tilesPerColumn-1 do
			local cell = grid[((y)*TileSize)+x+1]
			if cell == 0 then
				drawWall(x, y)
			end
		end
	end
end

local levelOnePlayerStartPosition = PD.geometry.point.new(11, 1)
local levelOneLadderPosition = PD.geometry.point.new(11, 12)
local level = Level(levelOnePlayerStartPosition, levelOneLadderPosition)

function PD.update()
	SLIB.update()
	drawGrid()
end
