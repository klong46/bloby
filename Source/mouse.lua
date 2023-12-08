import "CoreLibs/sprites"
import "constants"

local MOUSE_IMAGES <const> = {
    GFX.image.new('img/mouse/mouse_up'),
    GFX.image.new('img/mouse/mouse_down'),
    GFX.image.new('img/mouse/mouse_left'),
    GFX.image.new('img/mouse/mouse_right')
}

class('Mouse').extends(DynamicObject)

function Mouse:init(position, delay, grid)
    Mouse.super.init(self, MOUSE_IMAGES[1], position, DEFAULT_MOUSE_DIRECTION, grid, MOUSE_IMAGES)
    self.active = false
    self.delay = delay-1
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
    end
end

function Mouse:moveForward(playerMove)
    self.position = playerMove.position
    self:setDirectionImage(playerMove.direction)
    self.direction = playerMove.direction
end

function Mouse:move(playerMove, isForward, isStalled)
    if isForward then
        self:addPastMove()
        if self.active then
            if isStalled then
                self.stalledTurns += 1
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

