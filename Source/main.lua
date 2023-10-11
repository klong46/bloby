import "CoreLibs/graphics"


local gfx = playdate.graphics

local player = playdate.geometry.point.new(11, 1)
local finish = playdate.geometry.point.new(11, 12)

local w = 20
local h = 12
gfx.setColor(gfx.kColorBlack)

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
	gfx.fillRect(x*20, y*20, 20, 20)
end

local function drawLaser(x, y)
	gfx.setLineWidth(2)
	gfx.drawRect(x*20, y*20, 20, 20)
	gfx.drawRect(x*20+5, y*20+5, 10, 10)
end

local function drawGrid()
	gfx.setLineWidth(1)

	for x = 1, w do
		gfx.drawLine(x*20, 0, x*20, h*20)
	end

	for y = 1, h do
		gfx.drawLine(0, y*20, w*20, y*20)
	end

	for x = 0, w-1 do
		for y = 0, h-1 do
			local cell = grid[((y)*w)+x+1]
			if cell == 0 then
				drawWall(x, y)
			elseif cell == 2 then
				drawLaser(x, y)
			end
		end
	end
end



local function drawPlayer()
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.fillRoundRect((player.x-1)*w+3, (player.y-1)*w+3, 15, 15, 2)
	gfx.drawText("v", (player.x-1)*w+7, (player.y-1)*w)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

local function drawFinish()
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.fillRoundRect((finish.x-1)*w+3, (finish.y-1)*w+3, 15, 15, 2)
	gfx.drawText("e", (finish.x-1)*w+7, (finish.y-1)*w)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

drawPlayer()
drawFinish()
drawGrid()
function playdate.update()

	-- gfx.clear()

	
end
