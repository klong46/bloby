import "CoreLibs/sprites"
import "constants"

class('LaserSegment').extends(SLIB)

local laserAnimationTable = 'img/laser/laser_animation'
local laserHitAnimationTable = 'img/laser/laser_hit_animation'
local ANIMATION_SPEED = 40
local offset = {}

-- LASERS ARE DUPLICATING

function LaserSegment:init(direction, position, isEnd)
    LaserSegment.super.init(self)
    local imageTable = laserAnimationTable
    if isEnd then
        imageTable = laserHitAnimationTable
    end
    self.direction = direction
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, GFX.imagetable.new(imageTable), true)
    self:setOffsets()
    self:setZIndex(5)
    self:moveTo((position.x * TILE_SIZE) - offset[1], (position.y * TILE_SIZE) - offset[2])
    self:add()
end

function LaserSegment:setOffsets()
    local offsets = {{9, 11},{10, 10},{10, 10},{10, 11}}
    offset = GetByDirection(offsets, self.direction)
end

function LaserSegment:update()
    LaserSegment.super.update(self)
    if self.direction == DIRECTIONS.LEFT then
        self:setImage(self.animation:image(), GFX.kImageFlippedX)
    elseif self.direction == DIRECTIONS.RIGHT then
        self:setImage(self.animation:image())
    elseif self.direction == DIRECTIONS.UP then
        self:setImage(self.animation:image():rotatedImage(90), GFX.kImageFlippedY)
    elseif self.direction == DIRECTIONS.DOWN then
        self:setImage(self.animation:image():rotatedImage(90))
    end
end