import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "guard"
import "mouse"

class('Level').extends(SLIB)

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

local function getTile(x, y)
    return ((y-1)*TILES_PER_ROW)+x
end

function Level:drawTiles(playerDirection)
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local tile = self.grid[getTile(x, y)]
            local position = PD.geometry.point.new(x, y)
            if tile == WALL_TILE then
                Wall(position) -- create new wall at position
            elseif tile == GUARD_TILE then
                table.insert(self.guards, Guard(position))
            elseif tile == MOUSE_TILE then
                table.insert(self.mice, Mouse(position, self:getMouseDelay()))
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
                    self.player = Player(position, playerDirection)
                    self.grid[getTile(x, y)] = EMPTY_TILE
                elseif tile == LADDER_TILE then
                    self.ladder = Ladder(position)
                end
            end
        end
    end
end

function Level:init(file)
    Level.super.init(self)
    self.turn = 1
    laserCadenceIndex = 1
    laserOffsetIndex = 1
    mouseDelayIndex = 1
    local levelData = PD.datastore.read("levels/"..file)
    self.grid = levelData.grid
    self.laserCadences = levelData.laserCadences and levelData.laserCadences or {}
    self.laserOffsets = levelData.laserOffsets and levelData.laserOffsets or {}
    self.mouseDelays = levelData.mouseDelays and levelData.mouseDelays or {}
    self.guardDirections = levelData.guardDirections and levelData.guardDirections or {}
    local playerDirection = levelData.playerDirection and levelData.playerDirection or DEFAULT_PLAYER_DIRECTION
    self.laserBases = {}
    self.guards = {}
    self.mice = {}
    self:drawTiles(playerDirection)
    self:add()
end

local function updatePlayer(player, step, isForward)
    player:move(step, isForward)
end

local function updateGuards(guards, step, isForward, grid)
    for i, guard in ipairs(guards) do
        guard:move(step, isForward, grid)
    end
end

local function updateGuardDirections(guards, playerDirection)
    for i, guard in ipairs(guards) do
        guard:setDirection(playerDirection)
    end
end

local function updateLasers(laserBases, turn, grid)
    for i, laserBase in ipairs(laserBases) do
        local l = laserBase.laser
        l:setVisible(turn)
        l.length = l:setLength(grid)
        local image = l:getImage()
        l:setImage(image)
        l:setPosition(image)
    end
end

local function checkPlayerDeath(player, laserBases, turn, mice)
    if player:onLaser(laserBases, turn) or player:onMouse(mice) then
        ResetLevel()
    end
end

local function checkPlayerWin(player, grid)
    if player:onLadder(grid) then
        NextLevel()
    end
end

local function checkForBlocks(player, guards, grid)
    player:setIsBlocked(grid)
    for i, guard in ipairs(guards) do
        guard:setIsBlocked(grid)
    end
end

function Level:checkMouseInteractions()
end

function Level:checkPlayerInteractions()
    checkPlayerDeath(self.player, self.laserBases, self.turn, self.mice)
    checkPlayerWin(self.player, self.grid)
end

local function updateMouse(mice, player, isForward, delays)
    for i, mouse in ipairs(mice) do
        local delay = delays[i]
        if mouse.active then
            if mouse.delay >= 0 then
                mouse.delay -= 1
            else
                mouse.moving = true
                local nextMove = mouse.position
                if #player.pastMoves > delay then
                    nextMove = player.pastMoves[#player.pastMoves-delay].position
                end
                mouse:move(nextMove, isForward)
            end
        end
        if mouse.position == player.position then
            if isForward then
                mouse.active = true
            else
                mouse.active = false
                mouse.moving = false
                mouse.delay = delay
            end
        end
    end
end

function Level:updateGameObjects(step, isForward)
    self.turn += step
    updatePlayer(self.player, step, isForward)
    updateGuards(self.guards, step, isForward, self.grid)
    updateLasers(self.laserBases, self.turn, self.grid)
    updateMouse(self.mice, self.player, isForward, self.mouseDelays)
end

function Level:checkGuardInteractions()
    for i, guard in ipairs(self.guards) do
        if guard:onMouse(self.mice) then
            guard:remove()
        end
    end
end

function Level:updateTurn(step, isForward)
    if isForward then
        updateGuardDirections(self.guards, self.player.direction)
        checkForBlocks(self.player, self.guards, self.grid)
        if not self.player.isBlocked then
            self:updateGameObjects(step, isForward)
            self:checkGuardInteractions()
            self:checkPlayerInteractions()
            checkForBlocks(self.player, self.guards, self.grid) -- check if move is valid after turn ends
        end
    elseif self.player:hasPastMoves() then
        self:updateGameObjects(step, isForward)
    end
end

function Level:checkCrankTurns()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
        self:updateTurn(1, true)
    elseif ticks < 0 then
        self:updateTurn(-1, false)
    end
end

function Level:update()
    Level.super.update(self)
    self:checkCrankTurns()
end
