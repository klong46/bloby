import "CoreLibs/sprites"
import "dynamicObject"

local GUARD_IMAGES <const> = {
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard'),
    GFX.image.new('img/guard')
}

class('Guard').extends(DynamicObject)

function Guard:init(position, grid)
    Guard.super.init(self, GUARD_IMAGES[1], position, DEFAULT_GUARD_DIRECTION, grid, GUARD_IMAGES)
    self.alive = true
    self.lastPosition = position
end

function Guard:moveBack()
    local lastMove = Guard.super.moveBack(self)
    if lastMove then
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
    self.grid[GetTile(self.position.x, self.position.y)] = EMPTY_TILE
    self.alive = false
    self:setVisible(false)
end
