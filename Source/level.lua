import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "guard"
import "mouse"

local background = GFX.image.new('img/background_grid')

class('Level').extends(SLIB)

-- LEVEL: mirror image sides, control guard on other side

local laserCadenceIndex
local laserOffsetIndex
local mouseDelayIndex
-- laser offsets and cadences match with the lasers left to right on the grid 
-- (top to bottom for lasers in the same column)

local function getLevelArrayData(array, index, defaultValue)
    if index <= #(array) then
        local data = array[index]
        index += 1
        return data
    end
    return defaultValue
end

function Level:getLaserCadence()
    local cadence = getLevelArrayData(self.laserCadences, laserCadenceIndex, DEFAULT_LASER_CADENCE)
    laserCadenceIndex += 1
    return cadence
end

function Level:getLaserOffset()
    local offset = getLevelArrayData(self.laserOffsets, laserOffsetIndex, DEFAULT_LASER_OFFSET)
    laserOffsetIndex += 1
    return offset
end

function Level:getMouseDelay()
    local delay = getLevelArrayData(self.mouseDelays, mouseDelayIndex, DEFAULT_MOUSE_DELAY)
    mouseDelayIndex += 1
    return delay
end

function Level:init(file)
    Level.super.init(self)
    self.turn = 1
    Turn = self.turn
    laserCadenceIndex = 1
    laserOffsetIndex = 1
    mouseDelayIndex = 1
    local levelData = PD.datastore.read("levels/"..file)
    self.grid = levelData.grid
    self.laserCadences = levelData.laserCadences and levelData.laserCadences or {}
    self.laserOffsets = levelData.laserOffsets and levelData.laserOffsets or {}
    self.mouseDelays = levelData.mouseDelays and levelData.mouseDelays or {}
    self.guardDirections = levelData.guardDirections and levelData.guardDirections or {}
    self.starTargets = levelData.starTargets and levelData.starTargets or {}
    local playerDirection = levelData.playerDirection and levelData.playerDirection or DEFAULT_PLAYER_DIRECTION
    self.laserBases = {}
    self.guards = {}
    self.mice = {}
    self:drawTiles(playerDirection)
    self:setImage(background)
    self:setZIndex(4)
    self:moveTo(200,120)
    self:add()
end

function Level:drawTiles(playerDirection)
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local tile = self.grid[GetTile(x, y)]
            local position = PD.geometry.point.new(x, y)
            if tile == WALL_TILE then
                Wall(position)
            elseif tile == GUARD_TILE then
                table.insert(self.guards, Guard(position, self.grid))
            elseif tile == MOUSE_TILE then
                table.insert(self.mice, Mouse(position, self:getMouseDelay(), self.grid))
            else
                if tile == RIGHT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.RIGHT, self:getLaserCadence(), self:getLaserOffset()))
                elseif tile == LEFT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.LEFT, self:getLaserCadence(), self:getLaserOffset()))
                elseif tile == UP_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.UP, self:getLaserCadence(), self:getLaserOffset()))
                elseif tile == DOWN_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.DOWN, self:getLaserCadence(), self:getLaserOffset()))
                elseif tile == PLAYER_TILE then
                    self.player = Player(position, playerDirection, self.grid)
                    self.grid[GetTile(x, y)] = EMPTY_TILE
                elseif tile == LADDER_TILE then
                    self.ladder = Ladder(position)
                end
            end
        end
    end
end

function Level:update()
    if not LevelFinished then
        Level.super.update(self)
        if not self.player.isDead then
            self:checkCrankTurns()
        end
    end
end

function Level:checkCrankTurns()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
        self:moveForward()
    elseif ticks < 0 then
        self:moveBack()
    end
end

function Level:moveForward()
    self:updateGuardDirections()
    self:checkForBlocks()
    if not self.player.isBlocked then
        self:updateGameObjects(FORWARD_STEP, true)
        self:checkPlayerInteractions()
        self.player:setIsBlocked(PLAYER_OBSTACLES) -- check if move is valid after turn ends
    end
end

function Level:moveBack()
    if self.player:hasPastMoves() then
        self:updateGameObjects(BACKWARD_STEP, false)
    end
end

function Level:updateGuardDirections()
    for i, guard in ipairs(self.guards) do
        guard.direction = self.player.direction
    end
end

function Level:checkForBlocks()
    self.player:setIsBlocked(PLAYER_OBSTACLES)
    for i, guard in ipairs(self.guards) do
        guard:setIsBlocked(GUARD_OBSTACLES)
    end
end

function Level:updateGameObjects(step, isForward)
    self.turn += step
    Turn = self.turn
    self:updateGuards(step, isForward)
    self.player:move(step, isForward)
    self:updateMouse(isForward)
    self:checkGuardInteractions(isForward)
    self:updateLasers()
    for i, mouse in ipairs(self.mice) do
        mouse.stalled = mouse:onLaser(self.laserBases, self.turn)
    end

end

function Level:checkGuardInteractions(isForward)
    for i, guard in ipairs(self.guards) do
        if guard.alive and guard:onMouse(self.mice, isForward) then
            guard:destroy()
        end
    end
end

function Level:checkPlayerInteractions()
    self:checkPlayerDeath()
    self:checkPlayerWin()
end

function Level:guardListIncludes(value)
    for i, guard in ipairs(self.guards) do
        if guard.position == value then
            return true
        end
    end
    return false
end

function Level:updateGuards(step, isForward)
    local lastMoves = {}
    for i, guard in ipairs(self.guards) do
        guard:move(step, isForward, self.grid)
        table.insert(lastMoves, guard.lastPosition)
    end
    -- determines what tiles to rewrite as empty or as a guard
    for x, position in ipairs(lastMoves) do
        if not self:guardListIncludes(position) and
        self.grid[GetTile(position.x, position.y)] ~= LADDER_TILE and
        self.grid[GetTile(position.x, position.y)] ~= MOUSE_TILE  then
            self.grid[GetTile(position.x, position.y)] = EMPTY_TILE
        end
    end
end

function Level:updateLasers()
    for i, laserBase in ipairs(self.laserBases) do
        local laser = laserBase.laser
        laser.length = laser:setLength(self.grid)
        laser:setVisible(self.turn)
    end
end

function Level:checkPlayerDeath()
    if self.player:onLaser(self.laserBases, self.turn) then
        self.player.isDead = true
    elseif self.player:onMouse(self.mice, true) then
        self.player.isDead = true
        self.player:remove()
    end
end

function Level:getStars()
    local turns = self.turn - 1
    if turns > self.starTargets[1] then
        return 1
    elseif turns > self.starTargets[2] then
        return 2
    else
        return 3
    end
end

function Level:checkPlayerWin()
    if self.player:onLadder(self.grid) then
        self.ladder:remove()
        self.player:finishLevel(self:getStars())
    end
end

function Level:updateMouse(isForward)
    for i, mouse in ipairs(self.mice) do
        local delay = self.mouseDelays[i]-1 + mouse.stalledTurns
        local nextMove = mouse
        if #self.player.pastMoves > delay then
            nextMove = self.player.pastMoves[#self.player.pastMoves-delay+1]
        end
        mouse:move(nextMove, isForward, self.laserBases, self.turn)
        mouse:setActive(delay, self.player.position, isForward)
    end
end



