import "CoreLibs/sprites"
import "gameObject"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite

class('Laser').extends(GameObject)

local image = GFX.image.new('img/laser')

function Laser:init(position)
    Laser.super.init(self, image)
    self:setCenter(0.06, 0.5)
    self:moveTo((position.x * TileSize), (position.y * TileSize) - 10)
    self:add()
end

function Laser:setVisible(turn)
    if (turn+1) % 2 == 0 then
        self:remove()
    else
        self:add()
    end
end
