import "dragonScale"

class('Dragon').extends(SLIB)

local DRAGON_WIDTH = 5
local START_X = 5
local START_Y = 5

function Dragon:init(grid)
    Dragon.super.init(self)
    self.grid = grid
    self.direction = DIRECTIONS.RIGHT
    self.scales = {}
    self.blocked = false
    self:drawScales()
end

function Dragon:drawScales()
    for x=0,DRAGON_WIDTH-1 do
        for y=0,DRAGON_WIDTH-1 do
            table.insert(self.scales, DragonScale(PD.geometry.point.new(x+START_X, y+START_Y), self.direction, self.grid))
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
            if scale.alive then
                scale:setIsBlocked(GUARD_OBSTACLES)
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
            if self.scales[i]:onLaser(laserBases, turn) then
                self.scales[i].alive = false
            end
        end
    else
        for i, scale in ipairs(self.scales) do
            scale:moveBack()
            scale:setPosition()
        end
    end
end