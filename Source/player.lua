import "dynamicObject"
import "constants"
import "panel"

class('Player').extends(DynamicObject)

local DEATH_ANIMATION_SPEED = 22
local stars = 1
local PLAYER_IMAGES <const> = {
    GFX.image.new('img/player/player_up'),
    GFX.image.new('img/player/player_down'),
    GFX.image.new('img/player/player_left'),
    GFX.image.new('img/player/player_right')
}
local deathAnimationTable = GFX.imagetable.new('img/player/death_animation')

function Player:init(position, direction, grid, levelNum)
    Player.super.init(self, PLAYER_IMAGES[1], position, direction, grid, PLAYER_IMAGES)
    self.isDead = false
    self.levelNum = levelNum
    self.deathAnimation = GFX.animation.loop.new(DEATH_ANIMATION_SPEED, deathAnimationTable, false)
    self.deathAnimation.paused = true
    self.readingPanel = false
    self.fadeAnimator = nil
    self.panel = nil
    self:setZIndex(3)
    self:setDirectionImage(direction)
end

function Player:move(step, isForward)
    self:checkPanel()
    if isForward then
        self:addPastMove()
        self:moveForward(step)
        self:checkPanel()
    else
        self:moveBack()
    end
    self:setPosition()
end

function Player:onLadder()
    return self.grid[GetTile(self.position.x, self.position.y)] == LADDER_TILE
end

function Player:onDragon(dragon)
    for i, scale in ipairs(dragon.scales) do
        if scale.position == self.position and scale.alive then
            return true
        end
    end
    return false
end

function Player:finishLevel(starsEarned)
    LevelFinished = true
    stars = starsEarned
    LevelOver(stars)
    RemoveForwardTimer()
    RemoveBackTimer()
    self.fadeAnimator = GFX.animator.new(1500, 1, 0, PD.easingFunctions.outCubic)
end

function Player:checkPanel()
    self:lookingAtPanel()
    if self.readingPanel and not self.panel then
        self.panel = Panel(self.levelNum)
    elseif self.panel then
        self.panel:remove()
        self.panel = nil
    end
end

function Player:lookingAtPanel()
    local nextPosition = self:getNextTilePosition(self.position.x, self.position.y)
    local nextTile = self.grid[(GetTile(nextPosition[1], nextPosition[2]))]
    self.readingPanel = (nextTile == PANEL_TILE)
end

function Player:update()
    Player.super.update(self)
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
            EscapeTile(stars)
            self:remove()
        end
    end

end
