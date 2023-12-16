import "CoreLibs/sprites"
import "constants"

local inactiveImage = GFX.image.new('img/mouse/mouse_inactive')
local stallAnimationTable = GFX.imagetable.new('img/mouse/mouse_stalling_animation')
local STALL_ANIMATION_SPEED = 30
local MOUSE_IMAGES <const> = {
    GFX.image.new('img/mouse/mouse_up'),
    GFX.image.new('img/mouse/mouse_down'),
    GFX.image.new('img/mouse/mouse_left'),
    GFX.image.new('img/mouse/mouse_right')
}

class('Mouse').extends(DynamicObject)

function Mouse:init(position, delay, grid)
    Mouse.super.init(self, inactiveImage, position, DEFAULT_MOUSE_DIRECTION, grid, MOUSE_IMAGES)
    self.active = false
    self.delay = delay-1
    self.stallAnimation = GFX.animation.loop.new(STALL_ANIMATION_SPEED, stallAnimationTable, true)
    self.stalled = false
    self.stalledTurns = 0
end

function Mouse:setActive(delay, playerPosition, isForward)
    if isForward and (self.position == playerPosition) then
        self.active = true
    elseif (not isForward) and (self.delay == delay) and (self.position ~= playerPosition) then
        self.active = false
    end
end

function Mouse:moveBack()
    local lastMove = Mouse.super.moveBack(self)
    if lastMove then
        self.delay = lastMove.delay
        self.stalledTurns = lastMove.stalledTurns
        self.stalled = lastMove.stalled
    end
    if #self.pastMoves <= 1 or
      (#self.pastMoves > 1 and self.pastMoves[#self.pastMoves].delay ~= 0) then
        self:setImage(inactiveImage)
    end
end

function Mouse:moveForward(playerMove)
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
            self.stalled = self:onLaser(bases, turn)
        end
    else
        self:moveBack()
    end
    self:setPosition()
end

function Mouse:update()
    if self.stalled then
        self:setImage(self.stallAnimation:image())
    end
end

