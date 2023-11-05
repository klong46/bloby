import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "guard"
import "constants"

class('Level').extends(SLIB)

local laserCadenceIndex
local laserOffsetIndex
local guardDirectionIndex
-- laser offsets and cadences match with the lasers left to right on the grid 
-- (top to bottom for lasers in the same column)

function Level:getLaserCadence()
    if laserCadenceIndex <= #(self.laserCadences) then
        local cadence = self.laserCadences[laserCadenceIndex]
        laserCadenceIndex += 1
        return cadence
    end
    return DEFAULT_LASER_CADENCE
end

function Level:getLaserOffset()
    if laserOffsetIndex <= #(self.laserOffsets) then
        local offset = self.laserOffsets[laserOffsetIndex]
        laserOffsetIndex += 1
        return offset
    end
    return DEFAULT_LASER_OFFSET
end

function Level:getGuardDirection()
    if guardDirectionIndex <= #(self.guardDirections) then
        local direction = self.guardDirections[guardDirectionIndex]
        guardDirectionIndex += 1
        return direction
    end
    return DEFAULT_GUARD_POSITION
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
                table.insert(self.guards, Guard(position, self:getGuardDirection()))
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
                elseif tile == LADDER_TILE then
                    self.ladder = Ladder(position)
                end
            end
        end
    end
end

function Level:init(file)
    Level.super.init(self)
    self.move = 0
    self.turn = 1
    laserCadenceIndex = 1
    laserOffsetIndex = 1
    guardDirectionIndex = 1
    local levelData = PD.datastore.read("levels/"..file)
    self.grid = levelData.grid
    self.laserCadences = levelData.laserCadences and levelData.laserCadences or {}
    self.laserOffsets = levelData.laserOffsets and levelData.laserOffsets or {}
    self.guardDirections = levelData.guardDirections and levelData.guardDirections or {}
    local playerDirection = levelData.playerDirection and levelData.playerDirection or DEFAULT_PLAYER_DIRECTION
    self.laserBases = {}
    self.guards = {}
    self:drawTiles(playerDirection)
    self:add()
end

local function updatePlayer(player, step, isForward, grid)
    player:move(step, isForward, grid)
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
        l:setInitialPosition(image)
    end
end

local function checkPlayerDeath(player, laserBases, turn)
    if player:onLaser(laserBases, turn) then
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

function Level:checkPlayerInteractions()
    checkPlayerDeath(self.player, self.laserBases, self.turn)
    checkPlayerWin(self.player, self.grid)
end

function Level:updateGameObjects(step, isForward)
    self.turn += step
    updatePlayer(self.player, step, isForward, self.grid)
    updateGuards(self.guards, step, isForward, self.grid)
    updateLasers(self.laserBases, self.turn, self.grid)
end

function Level:updateTurn(step, isForward)
    if isForward then
        updateGuardDirections(self.guards, self.player.direction)
        checkForBlocks(self.player, self.guards, self.grid)
        if not self.player.isBlocked then
            self:updateGameObjects(step, isForward)
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
