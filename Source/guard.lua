import "dynamicObject"
import "constants"

class('Guard').extends(DynamicObject)

local animationTable = GFX.imagetable.new('img/guard_animation')
local ANIMATION_SPEED = 10
local ANIMATION_DELAY = 75
local explosionSound = playdate.sound.sampleplayer.new('snd/explosion')

function Guard:init(position, grid)
    Guard.super.init(self, nil, position, DEFAULT_GUARD_DIRECTION, grid, {})
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, animationTable, false)
    self.animationCount = 0
    self.alive = true
    self.lastPosition = position
    self:setImage(self.animation:image())
    self:setZIndex(1)
end

function Guard:moveBack()
    if self:hasPastMoves() then
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self.alive = lastMove.alive
    end
end

function Guard:move(step, isForward)
    self.lastPosition = PD.geometry.point.new(self.position.x, self.position.y)
    if isForward then
        self:addPastMove()
        if (not self.isBlocked) and (self.alive) then
            self:moveForward(step)
        end
    else
        self:moveBack()
        if self.alive then
            self:setVisible(true)
        end
    end
    self:setPosition()
    if self.alive then
        self.grid[GetTile(self.position.x, self.position.y)] = GUARD_TILE
    end
end

function Guard:destroy()
    explosionSound:play()
    self.grid[GetTile(self.position.x, self.position.y)] = EMPTY_TILE
    self.alive = false
    self:setVisible(false)
end

function Guard:update()
    Guard.super.update(self)
    self:setImage(self.animation:image())
    if not self.animation:isValid() then
        self.animationCount += 1
        if self.animationCount > ANIMATION_DELAY then
            self.animationCount = 0
            self.animation.frame = 1
            self.animation.paused = false
        end
    end
end
