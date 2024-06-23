import "constants"

class('DragonScale').extends(DynamicObject)

local deathAnimationTable = GFX.imagetable.new('img/dragon/scale_death_animation')
local DEATH_ANIMATION_SPEED = 50

local SCALE_IMAGE = GFX.image.new('img/dragon/scale')
local EYE_IMAGES = {
    GFX.image.new('img/dragon/dragon_eyes/eye_up'),
    GFX.image.new('img/dragon/dragon_eyes/eye_down'),
    GFX.image.new('img/dragon/dragon_eyes/eye_left'),
    GFX.image.new('img/dragon/dragon_eyes/eye_right')
    
}

function DragonScale:init(position, direction, grid, isEye)
    local image = SCALE_IMAGE
    if isEye then
        image = EYE_IMAGES[3]
    end
    DragonScale.super.init(self, image, position, direction, grid)
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
    self.alive = true
    self.isEye = isEye
    self:setZIndex(2)
    self:add()
end

function DragonScale:moveBack()
    if self:hasPastMoves() then
        self.lastDirection = self.pastMoves[#self.pastMoves].direction
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self.direction = lastMove.direction
        self.alive = lastMove.alive
        if self.alive then
            self:reanimate()
        end
    end
end

function DragonScale:getEyeImage()
    return GetByDirection(EYE_IMAGES, self.direction)
end

function DragonScale:reanimate()
    local image = SCALE_IMAGE
    if self.isEye then
        image = self:getEyeImage()
    end
    self:restartDeathAnimation()
    self:setImage(image)
    self:setVisible(true)
end

function DragonScale:restartDeathAnimation()
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
end

function DragonScale:update()
    DragonScale.super.update(self)
    if not self.alive and self:isVisible() then
        self.deathAnimation.paused = false
        self:setImage(self.deathAnimation:image())
        if not self.deathAnimation:isValid() then
            self:setVisible(false)
        end
    end
end