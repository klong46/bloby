import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"
import "constants"

class('Level').extends(SLIB)

function Level:drawWalls()
    for x = 1, TILES_PER_ROW do
        for y = 1, TILES_PER_COLUMN do
            local cell = self.grid[((y-1)*TILES_PER_ROW)+x]
            local position = PD.geometry.point.new(x, y)
            if cell == WALL_TILE then
                Wall(position)
            else
                if cell == RIGHT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.RIGHT))
                elseif cell == LEFT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.LEFT))
                elseif cell == RIGHT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.UP))
                elseif cell == RIGHT_LASER_TILE then
                    table.insert(self.laserBases, LaserBase(position, self.grid, DIRECTIONS.DOWN))
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
    self.step = 0
    self.turn = 0
    local levelData = PD.datastore.read("levels/"..file)
    self.grid = levelData.level
    self.player = Player(self:setSpritePosition('player'), levelData.playerDirection)
    self.ladder = Ladder(self:setSpritePosition('ladder'))
    self.laserBases = {}
    self:drawWalls()
    self:add()
end

-- local setPlayerStartPosition

local function updateGameObjectSteps(player, laserBases, step, turn)
    player:move(step)
    for i, laserBase in ipairs(laserBases) do
        laserBase.laser:setVisible(turn)
    end
end

function Level:setStep()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
        -- if ticks > 0 then
        self.step = 1
        -- elseif ticks < 0 then
            -- self.step = -1
        -- end
        if self.player:moveValid(self.grid) then
            self.turn += 1
            updateGameObjectSteps(self.player, self.laserBases, self.step, self.turn)
            if self.player:onLaser(self.laserBases, self.turn) then
                ResetLevel()
            elseif self.player:onLadder(self.grid) then
                NextLevel()
            end
            self.player:moveValid(self.grid)
        end
    end
end

function Level:update()
    Player.super.update(self)
    self:setStep()
end
