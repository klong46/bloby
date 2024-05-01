import "constants"

class('StaticObject').extends(SLIB)

function StaticObject:init(image, position)
    StaticObject.super.init(self)
    self:setImage(image)
    self:setPosition(position)
    self:add()
end

function StaticObject:setPosition(position)
    self:moveTo((position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end
