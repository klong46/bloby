import "CoreLibs/sprites"
import "constants"

class('DynamicObject').extends(SLIB)

function DynamicObject:init(image, position, direction, grid)
    DynamicObject.super.init(self)
    self.direction = direction
    self.position = position
    self.isBlocked = false
    self.grid = grid

    self:setImage(image)
    self:setPosition(position)
    self:add()
end

function DynamicObject:setPosition(position)
    self:moveTo((position.x * TILE_SIZE) - TILE_SPRITE_OFFSET, (position.y * TILE_SIZE) - TILE_SPRITE_OFFSET)
end

function DynamicObject:setDirectionImage(images, direction)
    self:setImage(GetByDirection(images, direction))
end
