import "CoreLibs/sprites"
import "constants"

class('LaserBase').extends(StaticObject)

local image = GFX.image.new('img/laser/laser_base')

function LaserBase:init(position, grid, direction, cadence, offset)
    LaserBase.super.init(self, image, position)
    self:setImage(self:getDirectionImage(direction))
    self:moveTo((position.x * TILE_SIZE) - 10, (position.y * TILE_SIZE) - 10)
    self.laser = Laser(position, grid, direction, cadence, offset)
end

function LaserBase:getDirectionImage(direction)
    local img = image
    if direction == DIRECTIONS.LEFT then
        img = image:rotatedImage(-90)
    elseif direction == DIRECTIONS.RIGHT then
        img = image:rotatedImage(90)
    elseif direction == DIRECTIONS.UP then
        img = image
    elseif direction == DIRECTIONS.DOWN then
        img = image:rotatedImage(180)
    end
    return img
end