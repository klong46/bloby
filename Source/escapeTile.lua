import "CoreLibs/sprites"
import "constants"

class('EscapeTile').extends(SLIB)

local image = GFX.image.new('img/finish_tile')
local position = PD.geometry.point.new(200,120)

function EscapeTile:init()
    EscapeTile.super.init(self)
    self:setImage(image)
    self:moveTo(position.x, position.y)
    self:setZIndex(6)
    self:add()
end

function EscapeTile:drawEscapeText()
    self.showEscapeText = true
end

function EscapeTile:update()
    
end