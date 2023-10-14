import "CoreLibs/sprites"
import "CoreLibs/crank"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Player').extends(SLIB)

local w = 20
local image = GFX.image.new('img/player')

function Player:init(position)
    Player.super.init(self)
    self.position = position
    self.step = 1
    self:setImage(image)
    
    self:add()
end

function Player:update()
    Player.super.update(self)
	self.position.y = self.step
    self:moveTo((self.position.x * w) - 9, (self.position.y * w) - 9)
end

function Player:setStep(nextStep)
    self.step = nextStep
end