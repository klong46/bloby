import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "level"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

local finish = PD.geometry.point.new(11, 12)

local w = 20
local h = 12

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
	GFX.fillRect(x*20, y*20, 20, 20)
end

local function drawLaserBase(x, y)
	GFX.setLineWidth(2)
	GFX.drawRect(x*w, y*w, 20, 20)
	GFX.drawRect(x*w+5, y*w+5, 10, 10)
end

local function drawLaser(x, y)
	GFX.setLineWidth(4)
	GFX.setLineCapStyle(GFX.kLineCapStyleRound)
	GFX.drawLine(x*w+10, y*w+10, 13*w-2, y*w+10)
end

local function drawGrid()
	GFX.setLineWidth(1)

	for x = 1, w do
		GFX.drawLine(x*20, 0, x*20, h*20)
	end

	for y = 1, h do
		GFX.drawLine(0, y*20, w*20, y*20)
	end

	for x = 0, w-1 do
		for y = 0, h-1 do
			local cell = grid[((y)*w)+x+1]
			if cell == 0 then
				drawWall(x, y)
			elseif cell == 2 then
				drawLaserBase(x, y)
				if Step % 2 == 0 then
					drawLaser(x, y)
				end
			end
		end
	end
end

local function drawFinish()
	GFX.setImageDrawMode(GFX.kDrawModeInverted)
	GFX.fillRoundRect((finish.x-1)*w+3, (finish.y-1)*w+3, 15, 15, 2)
	GFX.drawText("e", (finish.x-1)*w+7, (finish.y-1)*w)
	GFX.setImageDrawMode(GFX.kDrawModeCopy)
end

local level = Level()

function PD.update()
	SLIB.update()
	drawFinish()
	drawGrid()
end
