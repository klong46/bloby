import "dragonScale"
import "constants"

class('Dragon').extends(SLIB)

local DRAGON_WIDTH = 5
local START_X = 7
local START_Y = 2

function Dragon:init(grid)
    Dragon.super.init(self)
    self.grid = grid
    self.direction = DIRECTIONS.RIGHT
    self.scales = {}
    self.blocked = false
    self:drawScales()
end

function Dragon:isEye(x, y)
    if y == 2 then
        if x == 1 or x == 3 then
            return true
        end
    end
    return false
end

function Dragon:drawScales()
    for x=0,DRAGON_WIDTH-1 do
        for y=0,DRAGON_WIDTH-1 do
            table.insert(self.scales, DragonScale(PD.geometry.point.new(x+START_X, y+START_Y), self.direction, self.grid, self:isEye(x, y)))
        end
    end
end

function Dragon:move(step, isForward, laserBases, turn)
    for i, scale in ipairs(self.scales) do
        scale.lastPosition = PD.geometry.point.new(scale.position.x, scale.position.y)
    end
    if isForward then
        self.blocked = false
        for i, scale in ipairs(self.scales) do
            scale:addPastMove()
            if scale.alive and not self.blocked then
                if scale.isEye then scale:setImage(scale:getEyeImage()) end
                scale:setIsBlocked(DRAGON_OBSTACLES)
                if scale.isBlocked then self.blocked = true end
            end
        end
        if not self.blocked then
            for i, scale in ipairs(self.scales) do
                if scale.alive then
                    scale:moveForward(step)
                    scale:setPosition()
                end
            end
        end
        for i, scale in ipairs(self.scales) do
            if scale.alive then
                if scale:onLaser(laserBases, turn) then
                    scale.alive = false
                end
            end
        end
    else
        for i, scale in ipairs(self.scales) do
            scale:moveBack()
            scale:setPosition()
        end
    end
end