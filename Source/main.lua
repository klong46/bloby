import "CoreLibs/graphics"


local gfx = playdate.graphics

local cursor = playdate.geometry.point.new(2, 2)

local w = 20
local h = 12

local useDiagonals = false

local grid = {1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
			  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1}
			  
local path, graph, startNode, endNode

local function drawGrid()

	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(1)

	for x = 1, w do
		gfx.drawLine(x*20, 0, x*20, h*20)
	end

	for y = 1, h do
		gfx.drawLine(0, y*20, w*20, y*20)
	end

	for x = 0, w-1 do
		for y = 0, h-1 do
			if grid[((y)*w)+x+1] == 0 then
				gfx.fillRect(x*20, y*20, 20, 20)
			end
		end
	end

end

local function drawCursor()

	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(3)

	gfx.drawRect((cursor.x-1)*20, (cursor.y-1)*20, 21, 21)
end

local function drawStartAndEndSquares()

	gfx.setColor(gfx.kColorBlack)
	gfx.fillRoundRect(2, 2, 16, 16, 2)
	gfx.fillRoundRect(w*20-17, h*20-17, 15, 15, 2)

	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.drawText("s", 6, 0)
	gfx.drawText("e", w*20-13, h*20-20)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function playdate.update()

	gfx.clear()
	drawGrid()
	drawStartAndEndSquares()
	drawCursor()

end
