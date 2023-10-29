import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "constants"

class('Level').extends(SLIB)

local laserCadenceIndex
local laserOffsetIndex
-- laser offsets and cadences match with the lasers left to right on the grid 
-- (top to bottom for lasers in the same column)

function Level:getLaserCadence()
    if laserCadenceIndex <= #(self.laserCadences) then
        local cadence = self.laserCadences[laserCadenceIndex]
        laserCadenceIndex += 1
        return cadence
    end
    return 2
end

function Level:getLaserOffset()
    if laserOffsetIndex <= #(self.laserOffsets) then
        local offset = self.laserOffsets[laserOffsetIndex]
        laserOffsetIndex += 1
        return offset
    end
    return 0
end

function Level:drawWalls()
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local cell = self.grid[((y-1)*TILES_PER_ROW)+x]
            local position = PD.geometry.point.new(x, y)
            if cell == WALL_TILE then
                Wall(position)
            else
                if cell == RIGHT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.RIGHT, self:getLaserCadence(), self:getLaserOffset()))
                elseif cell == LEFT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.LEFT, self:getLaserCadence(), self:getLaserOffset()))
                elseif cell == UP_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.UP, self:getLaserCadence(), self:getLaserOffset()))
                elseif cell == DOWN_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.DOWN, self:getLaserCadence(), self:getLaserOffset()))
                end
            end
        end
    end
end

function Level:setSpritePosition(sprite)
    local spriteVal
    if sprite == 'player' then
        spriteVal = PLAYER_TILE
    elseif sprite == 'ladder' then
        spriteVal = LADDER_TILE
    end
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local cell = self.grid[((y-1)*TILES_PER_ROW)+x]
            if cell == spriteVal then
                return PD.geometry.point.new(x, y)
            end
        end
    end
    return PD.geometry.point.new(0, 0) -- default position if none is found
end

function Level:init(file)
    Level.super.init(self)
    self.move = 0
    self.turn = 1
    laserCadenceIndex = 1
    laserOffsetIndex = 1
    local levelData = PD.datastore.read("levels/"..file)
    self.grid = levelData.grid
    self.laserCadences = levelData.laserCadences and levelData.laserCadences or {}
    self.laserOffsets = levelData.laserOffsets and levelData.laserOffsets or {}
    local playerDir = levelData.playerDirection and levelData.playerDirection or DEFAULT_PLAYER_DIRECTION
    self.player = Player(self:setSpritePosition('player'), playerDir)
    self.ladder = Ladder(self:setSpritePosition('ladder'))
    self.laserBases = {}
    self:drawWalls()
    self:add()
end

local function updateGameObjectSteps(player, laserBases, step, turn)
    player:move(step)
    for i, laserBase in ipairs(laserBases) do
        laserBase.laser:setVisible(turn)
    end
end

function Level:incrementTurn(step)
    local isForward
    if step == 1 then
        isForward = true
    else
        isForward = false
    end
    if self.player:moveValid(self.grid, isForward) then
        self.turn += step
        updateGameObjectSteps(self.player, self.laserBases, step, self.turn)
        if self.player:onLaser(self.laserBases, self.turn) then
            ResetLevel()
        elseif self.player:onLadder(self.grid) then
            NextLevel()
        end
        self.player:moveValid(self.grid, isForward) -- check if move is valid after turn ends
    end
end

function Level:setStep()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
        self:incrementTurn(1)
    elseif ticks < 0 then
        self:incrementTurn(-1)
    end
end

function Level:update()

    Player.super.update(self)
    self:setStep()
end
