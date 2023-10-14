import "CoreLibs/sprites"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('GameObject').extends(SLIB)

function GameObject:init(image)
    GameObject.super.init(self)
    self:setImage(image)
    self:add()
end
