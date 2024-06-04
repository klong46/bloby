import "staticObject"
import "constants"

class('Floor').extends(StaticObject)

local images = {
    GFX.image.new('img/floors/floor_blank'),
    GFX.image.new('img/floors/floor_diag'),
}

function Floor:init(position)
    Floor.super.init(self, images[1], position)
    self:setImage(self:getImage(position))
    self:setZIndex(0)
    self:add()
end

function Floor:getImage(position)
    local offset = position.x + position.y
    if offset % 2 == 0 then
        return images[1]
    end
    return images[2]
end