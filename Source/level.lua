import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite
local CRANK_SPEED <const> = 6

class('Level').extends(SLIB)

local playerStartPos = PD.geometry.point.new(11, 1)

function Level:init()
    Level.super.init(self)
    self.move = 1
    self.step = 1
    self.player = Player(playerStartPos)
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
