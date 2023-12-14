import "CoreLibs/sprites"
import "constants"

class('LaserSegment').extends(SLIB)

local laserAnimationTable = 'img/laser/laser_animation'
local laserHitAnimationTable = 'img/laser/laser_hit_animation'
local ANIMATION_SPEED = 40
local X_OFFSET = 10
local Y_OFFSET = 10

function LaserSegment:init(direction, position, isEnd)
    LaserSegment.super.init(self)
    local imageTable = laserAnimationTable
    if isEnd then
        imageTable = laserHitAnimationTable
    end
    self.direction = direction
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, GFX.imagetable.new(imageTable), true)
    self:moveTo((position.x * TILE_SIZE) - X_OFFSET, (position.y * TILE_SIZE) - Y_OFFSET)
    self:add()
end

function LaserSegment:update()
    LaserSegment.super.update(self)
    if self.direction == DIRECTIONS.LEFT then
        self:setImage(self.animation:image():rotatedImage(180))
    elseif self.direction == DIRECTIONS.RIGHT then
        self:setImage(self.animation:image())
    elseif self.direction == DIRECTIONS.UP then
        self:setImage(self.animation:image():rotatedImage(-90))
    elseif self.direction == DIRECTIONS.DOWN then
        self:setImage(self.animation:image():rotatedImage(90))
    end
end