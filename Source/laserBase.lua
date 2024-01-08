import "CoreLibs/sprites"
import "constants"

class('LaserBase').extends(StaticObject)

local animationTable = GFX.imagetable.new('img/laser/laser_base_animation')
local ANIMATION_SPEED = 125

function LaserBase:init(position, grid, direction, cadence, offset)
    LaserBase.super.init(self, image, position)
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, animationTable, true)
    self.direction = direction
    self:moveTo((position.x * TILE_SIZE) - 10, (position.y * TILE_SIZE) - 10)
    self.laser = Laser(position, grid, direction, cadence, offset)
    self.animation.frame = math.random(1, animationTable:getLength())
    self:setAnimation()
end

function LaserBase:getDirectionImage(img)
    if self.direction == DIRECTIONS.UP then
        return img
    elseif self.direction == DIRECTIONS.RIGHT then
        return img:rotatedImage(90)
    elseif self.direction == DIRECTIONS.LEFT then
        return img:rotatedImage(-90)
    else
        return img:rotatedImage(180)
    end
end

function LaserBase:setAnimation()
    self:setImage(self:getDirectionImage(self.animation:image()))
    self.animation.paused = not self.laser:isVisible(Turn)
end

function LaserBase:update()
    LaserBase.super.update(self)
    self:setAnimation()
end
