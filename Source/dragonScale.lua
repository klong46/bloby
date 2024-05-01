import "constants"

class('DragonScale').extends(DynamicObject)

local SCALE_IMAGE = GFX.image.new('img/dragon/scale')
local deathAnimationTable = GFX.imagetable.new('img/dragon/scale_death_animation')
local DEATH_ANIMATION_SPEED = 50

function DragonScale:init(position, direction, grid)
    DragonScale.super.init(self, SCALE_IMAGE, position, direction, grid)
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
    self.alive = true
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

function DragonScale:reanimate()
    self:restartDeathAnimation()
    self:setImage(SCALE_IMAGE)
    self:setVisible(true)
end

function DragonScale:restartDeathAnimation()
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
end

function DragonScale:update()
    DragonScale.super.update(self)
    if not self.alive then
        self.deathAnimation.paused = false
        self:setImage(self.deathAnimation:image())
        if not self.deathAnimation:isValid() then
            self:setVisible(false)
        end
    end
end