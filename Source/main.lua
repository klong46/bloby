import "CoreLibs/graphics"
import "CoreLibs/crank"


local gfx = playdate.graphics

local player = playdate.geometry.point.new(11, 1)
local finish = playdate.geometry.point.new(11, 12)

local w = 20
local h = 12
local step = 0

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

local function drawLaserBase(x, y)
	gfx.setLineWidth(2)
	gfx.drawRect(x*w, y*w, 20, 20)
	gfx.drawRect(x*w+5, y*w+5, 10, 10)
end

local function drawLaser(x, y)
	gfx.setLineWidth(4)
	gfx.setLineCapStyle(gfx.kLineCapStyleRound)
	gfx.drawLine(x*w+10, y*w+10, 13*w-2, y*w+10)
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
				drawLaserBase(x, y)
				if step % 2 == 0 then
					drawLaser(x, y)
				end
			end
		end
	end
end

local function drawPlayer()
	local x = (player.x-1)*w
	local y = (player.y-1)*w
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.fillRoundRect(x+3, y+3, 15, 15, 2)
	gfx.drawText("v", x+7, y)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

local function drawFinish()
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.fillRoundRect((finish.x-1)*w+3, (finish.y-1)*w+3, 15, 15, 2)
	gfx.drawText("e", (finish.x-1)*w+7, (finish.y-1)*w)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

local function moveStep(d)
	step += d
end


function playdate.update()

	gfx.clear()
	drawPlayer()
	drawFinish()
	drawGrid()

	local ticks = playdate.getCrankTicks(6)
    if ticks > 0 then
        moveStep(1)
		player.y += 1
    elseif ticks < 0 then
		moveStep(-1)
		player.y -= 1
	end
end
