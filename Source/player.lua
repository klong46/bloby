import "CoreLibs/sprites"
import "dynamicObject"
import "constants"

local PLAYER_IMAGES <const> = {
    GFX.image.new('img/player/player_up'),
    GFX.image.new('img/player/player_down'),
    GFX.image.new('img/player/player_left'),
    GFX.image.new('img/player/player_right')
}

class('Player').extends(DynamicObject)

function Player:init(position, direction, grid)
    Player.super.init(self, PLAYER_IMAGES[1], position, direction, grid, PLAYER_IMAGES)
    self:setDirectionImage(direction)
end

function Player:move(step, isForward)
    if isForward then
        self:addPastMove()
        self:moveForward(step)
    else
        self:moveBack()
    end
    self:setPosition()
end



-- local function isObstacle(tile)
--     return not (tile == EMPTY_TILE or tile == LADDER_TILE or tile == MOUSE_TILE)
-- end

local function onBorder(x, y, direction)
    if (direction == DIRECTIONS.UP) then
        return y < 1
    elseif (direction == DIRECTIONS.DOWN) then
        return y > TILES_PER_COLUMN
    elseif (direction == DIRECTIONS.LEFT) then
        return x < 1
    elseif (direction == DIRECTIONS.RIGHT) then
        return x > TILES_PER_ROW
    end
end

function Player:onLadder()
    return self.grid[GetTile(self.position.x, self.position.y)] == LADDER_TILE
end

function Player:onLaser(laserBases, turn)
    local allLaserTilePositions = {}
    for i, laserBase in ipairs(laserBases) do
        if laserBase.laser:isVisible(turn) then
            table.insert(allLaserTilePositions, laserBase.laser:getTilePositions())
        end
    end
    for i, positionTable in ipairs(allLaserTilePositions) do
        for y, position in ipairs(positionTable) do
            if position == self.position then
                return true
            end
        end
    end
    return false
end

function Player:onMouse(mice)
    for i, mouse in ipairs(mice) do
        local lastPosition = self.pastMoves[#self.pastMoves].position
        local lastMousePosition = mouse.pastMoves[#mouse.pastMoves].position
        if ((mouse.position == self.position) or
           ((mouse.position == lastPosition) and (lastMousePosition == self.position))) and
           (mouse.delay == 0) then
            return true
        end
    end
    return false
end

function Player:setIsBlocked(grid)
    self.isBlocked = self:nextTileIsObstacle(self.position.x, self.position.y)
end

function Player:update()
    Player.super.update(self)
    if PD.buttonIsPressed(PD.kButtonUp) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.UP)
        self.direction = DIRECTIONS.UP
    end
    if PD.buttonIsPressed(PD.kButtonDown) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.DOWN)
        self.direction = DIRECTIONS.DOWN
    end
    if PD.buttonIsPressed(PD.kButtonLeft) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.LEFT)
        self.direction = DIRECTIONS.LEFT
    end
    if PD.buttonIsPressed(PD.kButtonRight) and self.isBlocked then
        self:setDirectionImage(DIRECTIONS.RIGHT)
        self.direction = DIRECTIONS.RIGHT
    end
end
