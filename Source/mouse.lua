import "constants"

class('Mouse').extends(DynamicObject)

local inactiveImage = GFX.image.new('img/mouse/mouse_inactive')
local stallAnimationTable = GFX.imagetable.new('img/mouse/mouse_stalling_animation')
local eatAnimationTable = GFX.imagetable.new('img/mouse/mouse_eat_animation')
local STALL_ANIMATION_SPEED = 30
local EAT_ANIMATION_SPEED = 30

local awakeSound = playdate.sound.sampleplayer.new('snd/mouse_awake')


local MOUSE_IMAGES <const> = {
    GFX.image.new('img/mouse/mouse_up'),
    GFX.image.new('img/mouse/mouse_down'),
    GFX.image.new('img/mouse/mouse_left'),
    GFX.image.new('img/mouse/mouse_right')
}

function Mouse:init(position, delay, grid)
    Mouse.super.init(self, inactiveImage, position, DEFAULT_MOUSE_DIRECTION, grid, MOUSE_IMAGES)
    self.active = false
    self.delay = delay-1
    self.stallAnimation = GFX.animation.loop.new(STALL_ANIMATION_SPEED, stallAnimationTable, true)
    self.eatAnimation = GFX.animation.loop.new(EAT_ANIMATION_SPEED, eatAnimationTable, false)
    self.eatAnimation.paused = true
    self.eating = false
    self.stalled = false
    self.stalledTurns = 0
    self.gameOver = false
    self.awoken = false
    self:setZIndex(2)
end

function Mouse:setActive(delay, playerPosition, isForward)
    if isForward and (self.position == playerPosition) then
        self.active = true
    elseif (not isForward) and (self.delay == delay) and (self.position ~= playerPosition) then
        self.active = false
    end
end

function Mouse:moveBack()
    self:restartEatAnimation()
    local lastMove = Mouse.super.moveBack(self)
    if lastMove then
        self.delay = lastMove.delay
        self.stalledTurns = lastMove.stalledTurns
        self.stalled = lastMove.stalled
    end
    if self:isInactive() then
        self:setImage(inactiveImage)
        self.awoken = false
    end
end

function Mouse:isInactive()
    return #self.pastMoves <= 1 or
          (#self.pastMoves > 1 and self.pastMoves[#self.pastMoves].delay ~= 0)
end

function Mouse:moveForward(playerMove)
    if not self.awoken then
        awakeSound:play()
        self.awoken = true
    end
    self.position = playerMove.position
    self:setDirectionImage(playerMove.direction)
    self.direction = playerMove.direction
end

function Mouse:move(playerMove, isForward, bases, turn)
    if isForward then
        self:addPastMove()
        if self.active then
            self.stalled = self:onLaser(bases, turn)
            if self.stalled then
                self.stalledTurns += 1
                self.stalled = true
            else
                if self.delay == 0 then
                    self:moveForward(playerMove)
                else
                    self.delay -= 1
                end
            end
        end
    else
        self:moveBack()
    end
    self:setPosition()
end

function Mouse:restartEatAnimation()
    self.eatAnimation = GFX.animation.loop.new(EAT_ANIMATION_SPEED, eatAnimationTable, false)
    self.eatAnimation.paused = true
    self.eating = false
end

function Mouse:update()
    if self.eating then
        self.eatAnimation.paused = false
        self:setImage(self.eatAnimation:image())
        if not self.eatAnimation:isValid() then
            self:restartEatAnimation()
            if self.gameOver then
                ResetLevel()
            end
        end
    elseif self.stalled and self.awoken then
        self:setImage(self.stallAnimation:image())
    else
        if self:isInactive() then
            self:setImage(inactiveImage)
        else
            self:setDirectionImage(self.direction)
        end
    end
end

