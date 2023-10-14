import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite
local CRANK_SPEED <const> = 6

class('Level').extends(SLIB)

local tilesPerRow = 20
local tilesPerColumn = 12

local levelOneGrid = {0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}

local function drawWalls()
    for x = 1, tilesPerRow do
        for y = 1, tilesPerColumn do
            local cell = levelOneGrid[((y-1)*tilesPerRow)+x]
            if cell == 1 then
                local position = PD.geometry.point.new(x, y)
                Wall(position)
            elseif cell == 2 then
                local position = PD.geometry.point.new(x, y)
                LaserBase(position)
            end
        end
    end
end

function Level:init(playerStartPosition, ladderPosition)
    Level.super.init(self)
    self.move = 1
    self.step = 1
    self.player = Player(playerStartPosition)
    self.ladder = Ladder(ladderPosition)
    drawWalls()
    self:add()
end

function Level:setStep()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
		self.step += 1
    elseif ticks < 0 then
		self.step -= 1
	end
end

function Level:update()
    Player.super.update(self)
    self:setStep()
    self.player:setStep(self.step)
end
