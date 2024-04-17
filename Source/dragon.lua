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
    self:drawScales()
end

function Dragon:drawScales()
    for y=0,DRAGON_WIDTH do
        for x=0,DRAGON_WIDTH do
            table.insert(self.scales, DragonScale(PD.geometry.point.new(x+START_X, y+START_Y), self.direction, self.grid))
        end
    end
end

function Dragon:move(step, isForward)
    -- self.lastPosition = PD.geometry.point.new(self.position.x, self.position.y)
    if isForward then
        -- self:addPastMove()
        for i, scale in ipairs(self.scales) do
            scale:setIsBlocked(GUARD_OBSTACLES)
            if scale.isBlocked then return end
        end
        for i, scale in ipairs(self.scales) do
            scale:moveForward(step)
            scale:setPosition()
        end
        
    else
        -- self:moveBack()
        -- if self.alive then
        --     self:setVisible(true)
        -- end
    end
    
    -- if self.alive then
    --     self.grid[GetTile(self.position.x, self.position.y)] = GUARD_TILE
    -- end
end

