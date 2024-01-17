import "CoreLibs/sprites"
import "CoreLibs/animation"
import "dynamicObject"
import "constants"

local DEATH_ANIMATION_SPEED = 22
local stars = 1

local PLAYER_IMAGES <const> = {
    GFX.image.new('img/player/player_up'),
    GFX.image.new('img/player/player_down'),
    GFX.image.new('img/player/player_left'),
    GFX.image.new('img/player/player_right')
}
local deathAnimationTable = GFX.imagetable.new('img/player/death_animation')

class('Player').extends(DynamicObject)

function Player:init(position, direction, grid)
    Player.super.init(self, PLAYER_IMAGES[1], position, direction, grid, PLAYER_IMAGES)
    self.isDead = false
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
    self.fadeAnimator = nil
    self:setZIndex(3)
    self:setDirectionImage(direction)
end

function Player:move(step, isForward)
    if isForward then
        self:addPastMove()
        self:moveForward(step)
    else
        self:moveBack()
    end
    self:setPosition()
end

function Player:onLadder()
    return self.grid[GetTile(self.position.x, self.position.y)] == LADDER_TILE
end

function Player:finishLevel(starsEarned)
    stars = starsEarned
    self.fadeAnimator = GFX.animator.new(1500, 1, 0, PD.easingFunctions.outCubic)
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.UP)
        self.direction = DIRECTIONS.UP
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.DOWN)
        self.direction = DIRECTIONS.DOWN
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.LEFT)
        self.direction = DIRECTIONS.LEFT
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.RIGHT)
        self.direction = DIRECTIONS.RIGHT
    end

    if self.isDead then
        self.deathAnimation.paused = false
        self:setImage(self.deathAnimation:image())
        if not self.deathAnimation:isValid() then
            ResetLevel()
        end
    end

    if self.fadeAnimator then
        local fadedImage = self:getImage():fadedImage(self.fadeAnimator:currentValue(), GFX.image.kDitherTypeBurkes)
        self:setImage(fadedImage)
        if self.fadeAnimator:ended() then
            LevelOver(stars)
            self:remove()
        end
    end

end
