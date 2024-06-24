import "CoreLibs/sprites"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "guard"
import "mouse"
import "dragon"
import "movesTile"
import "floor"

class('Level').extends(SLIB)

local background = GFX.image.new('img/background_grid')
local deathSound = playdate.sound.sampleplayer.new('snd/death_sound')
local winSound = playdate.sound.sampleplayer.new('snd/win_sound')

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

function Level:init(levelNum)
    Level.super.init(self)
    self.turn = 1
    Turn = self.turn
    laserCadenceIndex = 1
    laserOffsetIndex = 1
    mouseDelayIndex = 1
    local levelData = PD.datastore.read("levels/1-"..levelNum)
    self.levelNum = levelNum
    self.grid = levelData.grid
    self.laserCadences = levelData.laserCadences and levelData.laserCadences or {}
    self.laserOffsets = levelData.laserOffsets and levelData.laserOffsets or {}
    self.mouseDelays = levelData.mouseDelays and levelData.mouseDelays or {}
    self.guardDirections = levelData.guardDirections and levelData.guardDirections or {}
    self.starTargets = levelData.starTargets and levelData.starTargets or {}
    self.movesPosition = levelData.movesPosition and levelData.movesPosition or {}
    local playerDirection = levelData.playerDirection and levelData.playerDirection or DEFAULT_PLAYER_DIRECTION
    self.laserBases = {}
    self.guards = {}
    self.mice = {}
    self.dragon = nil
    self:drawTiles(playerDirection)
    self:setImage(background)
    self:setZIndex(4)
    self:moveTo(200,120)
    StartThemeMusic(levelNum)
    self.levelNumScreen = LevelNumScreen(levelNum)
    self:add()
end

-- gross but determines if wall is surrounded and should have a pattern
function Level:wallIsSurrounded(x, y)
    if (x == 1 or self.grid[GetTile(x-1, y)] == nil or self.grid[GetTile(x-1, y)] == WALL_TILE) and
       (x == TILES_PER_ROW or self.grid[GetTile(x+1, y)] == nil or self.grid[GetTile(x+1, y)] == WALL_TILE) and
       (self.grid[GetTile(x, y-1)] == nil or self.grid[GetTile(x, y-1)] == WALL_TILE) and
       (self.grid[GetTile(x, y+1)] == nil or self.grid[GetTile(x, y+1)] == WALL_TILE) and

       (x == 1 or self.grid[GetTile(x-1, y-1)] == nil or self.grid[GetTile(x-1, y-1)] == WALL_TILE) and
       (x == TILES_PER_ROW or self.grid[GetTile(x+1, y+1)] == nil or self.grid[GetTile(x+1, y+1)] == WALL_TILE) and
       (x == TILES_PER_ROW or self.grid[GetTile(x+1, y-1)] == nil or self.grid[GetTile(x+1, y-1)] == WALL_TILE) and
       (x == 1 or self.grid[GetTile(x-1, y+1)] == nil or self.grid[GetTile(x-1, y+1)] == WALL_TILE) then
        return true
    end
    return false
end

function Level:drawTiles(playerDirection)
    -- create dragon if bonus level
    if self.levelNum == BONUS_LEVEL then
        self.dragon = Dragon(self.grid)
    end
    MovesTile(PD.geometry.point.new(self.movesPosition[1], self.movesPosition[2]))
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local tile = self.grid[GetTile(x, y)]
            local position = PD.geometry.point.new(x, y)
            if tile == WALL_TILE then
                Wall(position, self:wallIsSurrounded(x, y))
            elseif tile == EMPTY_TILE then
                Floor(position)
            elseif tile == GUARD_TILE then
                table.insert(self.guards, Guard(position, self.grid))
                Floor(position)
            elseif tile == MOUSE_TILE then
                table.insert(self.mice, Mouse(position, self:getMouseDelay(), self.grid))
                Floor(position)
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
                    if self.levelNum == BONUS_LEVEL then
                        self.ladder:hide()
                    end
                end
            end
        end
    end
end

function Level:update()
    -- If the level is finished, freeze all sprite updates
    if not LevelFinished then
        Level.super.update(self)
        if not self.player.isDead then
            self:checkCrankTurns()
        end
    end
end

-- Updates the level based on the crank turns
function Level:checkCrankTurns()
    if CrankTicks > 0 then
        self:moveForward()
    elseif CrankTicks < 0 then
        self:moveBack()
    end
end

function Level:moveForward()
    self:updateGuardDirections()
    if self.levelNum == BONUS_LEVEL then
        self:updateDragonDirection()
    end
    self.player:setIsBlocked(PLAYER_OBSTACLES)
    self:checkForGuardBlocks()
    if not self.player.isBlocked then
        self:updateGameObjects(FORWARD_STEP, true)
        self:checkPlayerInteractions()
        -- check if move is valid after turn ends
        self.player:setIsBlocked(PLAYER_OBSTACLES)
    end
    if self.levelNumScreen and not self.levelNumScreen.dismissed then
        self.levelNumScreen.dismissed = true
        self.levelNumScreen.text.dismissed = true
    end
end

function Level:moveBack()
    if self.player:hasPastMoves() then
        self:updateGameObjects(BACKWARD_STEP, false)
    end
end

-- Updates the game objects based on the step and direction
function Level:updateGameObjects(step, isForward)
    self.turn += step
    Turn = self.turn
    self:updateGuards(step, isForward)
    self.player:move(step, isForward)
    self:updateMouse(isForward)
    self:checkGuardDeath(isForward)
    self:updateLasers()
    for i, mouse in ipairs(self.mice) do
        mouse.stalled = mouse:onLaser(self.laserBases, self.turn)
    end
    if self.levelNum == BONUS_LEVEL then
        self:updateDragon(step, isForward, self.laserBases, self.turn)
        if self:dragonIsDead() then
            self:showLadder()
        elseif not isForward then
            self.ladder:setVisible(false)
        end
    end
end

-- Only used on the bonus level to show the ladder when the dragon is dead.
function Level:showLadder()
    if not self.ladder:isVisible() then
        self.ladder:show()
    end
end

-- PLAYER FUNCTIONS:
function Level:checkPlayerInteractions()
    self:checkPlayerDeath()
    self:checkPlayerWin()
end

function Level:playerDies()
    ThemeMusic:stop()
    self.player.isDead = true
    deathSound:play()
end

function Level:checkPlayerDeath()
    if self.levelNum == BONUS_LEVEL then
        if self.player:onDragon(self.dragon) then
            self:playerDies()
        end
    end
    if self.player:onLaser(self.laserBases, self.turn) then
        self:playerDies()
    elseif self.player:onMouse(self.mice, true) then
        self:playerDies()
        self.player:remove()
    end
end

function Level:checkPlayerWin()
    if self.player:onLadder(self.grid) then
        if self.levelNum == BONUS_LEVEL then
            BossMusic:setVolume(0.2)
        else
            ThemeMusic:setVolume(0.2)
        end
        winSound:play()
        self.ladder:remove()
        self.player:finishLevel(self:getStars())
    end
end

-- GUARD FUNCTIONS:
function Level:updateGuards(step, isForward)
    local lastMoves = {}
    for i, guard in ipairs(self.guards) do
        guard:move(step, isForward)
        table.insert(lastMoves, guard.lastPosition)
    end
    -- Determines what tiles to rewrite as empty or as a guard.
    for x, position in ipairs(lastMoves) do
        if not self:guardListIncludes(position) and
        self.grid[GetTile(position.x, position.y)] ~= LADDER_TILE and
        self.grid[GetTile(position.x, position.y)] ~= MOUSE_TILE then
            self.grid[GetTile(position.x, position.y)] = EMPTY_TILE
        end
    end
end

function Level:checkGuardDeath(isForward)
    for i, guard in ipairs(self.guards) do
        if guard.alive and guard:onMouse(self.mice, isForward) then
            guard:destroy()
        end
    end
end

function Level:updateGuardDirections()
    for i, guard in ipairs(self.guards) do
        guard.direction = self.player.direction
    end
end

-- Checks if the guard list includes a certain position.
function Level:guardListIncludes(value)
    for i, guard in ipairs(self.guards) do
        if guard.alive and guard.position == value then
            return true
        end
    end
    return false
end

function Level:checkForGuardBlocks()
    for i, guard in ipairs(self.guards) do
        guard:setIsBlocked(GUARD_OBSTACLES)
    end
end


-- LASER FUNCTIONS:
function Level:updateLasers()
    for i, laserBase in ipairs(self.laserBases) do
        local laser = laserBase.laser
        laser.length = laser:setLength(self.grid)
        laser:setVisible(self.turn)
    end
end


-- MOUSE FUNCTIONS:
-- Updates the mouse movement
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

-- STAR FUNCTIONS:
-- Constants for star ratings
local STAR_RATING_ONE = 1
local STAR_RATING_TWO = 2
local STAR_RATING_THREE = 3

-- Returns the number of stars earned based on the number of turns taken
function Level:getStars()
    local turns = self.turn - 1
    if turns > self.starTargets[1] then
        return STAR_RATING_ONE
    elseif turns > self.starTargets[2] then
        return STAR_RATING_TWO
    else
        return STAR_RATING_THREE
    end
end

-- DRAGON FUNCTIONS:
function Level:updateDragon(step, isForward, laserBases, turn)
    self.dragon:move(step, isForward, laserBases, turn)
end

function Level:dragonIsDead()
    for i, scale in ipairs(self.dragon.scales) do
        if scale.alive then
            return false
        end
    end
    return true
end

function Level:updateDragonDirection()
    for i, scale in ipairs(self.dragon.scales) do
        -- opposite of player direction
        scale.direction = self.player.direction * -1
    end
end