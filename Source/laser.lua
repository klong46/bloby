import "constants"
import "laserSegment"

class('Laser').extends(SLIB)

function Laser:init(position, grid, direction, cadence, offset)
    Laser.super.init(self)
    self.origin = position
    self.direction = direction
    self.cadence = cadence
    self.offset = offset
    self.length = self:setLength(grid)
    self.segments = {}
    self:createSegments(1, self.length)
    self:setCenter(0, 0.5)
    self:setVisible(Turn)
    self:add()
end

function Laser:createSegments(start, numSegments)
    for i = start, numSegments, 1 do
        local position = self:getLaserSegmentPosition(i)
        table.insert(self.segments, LaserSegment(self.direction, position, (i == self.length)))
    end
end

function Laser:getLaserSegmentPosition(segmentNum)
    local opts = {
        PD.geometry.point.new(self.origin.x, self.origin.y - segmentNum),
        PD.geometry.point.new(self.origin.x, self.origin.y + segmentNum),
        PD.geometry.point.new(self.origin.x - segmentNum, self.origin.y),
        PD.geometry.point.new(self.origin.x + segmentNum, self.origin.y)
    }
    return GetByDirection(opts, self.direction)
end

function Laser:setVisible(turn)
    if not self:isVisible(turn) then
        for i = 1, #self.segments, 1 do
            self.segments[i]:remove()
        end
    else
        if self.length > #self.segments then
            self:createSegments(#self.segments+1, self.length)
        end
        for x = self.length+1, #self.segments, 1 do
            self.segments[x]:remove()
        end
        for i = 1, self.length, 1 do
            if i == self.length then
                self.segments[i]:setAnimation(true)
            else
                self.segments[i]:setAnimation(false)
            end
            self.segments[i]:add()
        end
    end
end

function Laser:isVisible(turn)
    return not ((turn + self.offset) % self.cadence == 0)
end

local function laserBlocked(position)
    return (position ~= EMPTY_TILE) and (position ~= PLAYER_TILE)
end

local function getTile(x, y, grid)
    return grid[(y-1) * TILES_PER_ROW + x]
end

local function getLaserPositionValue(direction, origin, i, grid)
    if (direction == DIRECTIONS.UP) then
        return getTile(origin.x, origin.y-i, grid)
    elseif (direction == DIRECTIONS.DOWN) then
        return getTile(origin.x, origin.y+i, grid)
    elseif (direction == DIRECTIONS.LEFT) then
        return getTile(origin.x-i, origin.y, grid)
    elseif (direction == DIRECTIONS.RIGHT) then
        return getTile(origin.x+i, origin.y, grid)
    end
end

function Laser:setLength(grid)
    local maxLength
    if self.direction == DIRECTIONS.UP or self.direction == DIRECTIONS.DOWN then
        maxLength = TILES_PER_COLUMN-1
    else
        maxLength = TILES_PER_ROW-1
    end
    for i=1,maxLength do
        local position = getLaserPositionValue(self.direction, self.origin, i, grid)
        if laserBlocked(position) then
            return i-1
        end
    end
    return maxLength -- if laser if full length of screen (no obstacles)
end

function Laser:getTilePositions()
    local tiles = {}
    local stepDirection = 1
    if self.direction == DIRECTIONS.LEFT or self.direction == DIRECTIONS.UP then
        stepDirection = -1
    end
    if self.direction == DIRECTIONS.LEFT or self.direction == DIRECTIONS.RIGHT then
        for i = 1, self.length do
            table.insert(tiles, PD.geometry.point.new(self.origin.x + (i * stepDirection), self.origin.y))
        end
    elseif self.direction == DIRECTIONS.UP or self.direction == DIRECTIONS.DOWN then
        for i = 1, self.length do
            table.insert(tiles, PD.geometry.point.new(self.origin.x, self.origin.y + (i * stepDirection)))
        end
    end
    return tiles
end
