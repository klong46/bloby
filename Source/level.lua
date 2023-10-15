import "CoreLibs/sprites"
import "CoreLibs/crank"
import "player"
import "ladder"
import "wall"
import "laserBase"
import "laser"

local PD <const> = playdate
local GFX <const> = PD.graphics
local SLIB <const> = GFX.sprite
local CRANK_SPEED <const> = 6

class('Level').extends(SLIB)

local tilesPerRow = 20
local tilesPerColumn = 12

function Level:drawWalls()
    for x = 1, tilesPerRow do
        for y = 1, tilesPerColumn do
            local cell = self.file.level[((y-1)*tilesPerRow)+x]
            if cell == 1 then
                local position = PD.geometry.point.new(x, y)
                Wall(position)
            elseif cell == 2 then
                local position = PD.geometry.point.new(x, y)
                LaserBase(position)
                table.insert(self.lasers, Laser(position))
            end
        end
    end
end

function Level:init(playerStartPosition, ladderPosition, file)
    Level.super.init(self)
    self.move = 0
    self.step = 0
    self.turn = 0
    self.file = PD.datastore.read("levels/"..file)
    self.player = Player(playerStartPosition)
    self.ladder = Ladder(ladderPosition)
    self.lasers = {}
    self:drawWalls()
    self:add()
end

local function updateGameObjectSteps(player, lasers, step, turn)
    player:move(step)
    for i, laser in ipairs(lasers) do
        laser:setVisible(turn)
    end
end

local function playerBoundsValid(step, playerPosition)
    if step < 0 and playerPosition.y == 1
    or step > 0 and playerPosition.y == TilesPerColumn then
        return false
    end
    return true
end

function Level:setStep()
	local ticks = PD.getCrankTicks(CRANK_SPEED)
    if ticks ~= 0 then
        if ticks > 0 then
            self.step = 1
        elseif ticks < 0 then
            self.step = -1
        end
        if playerBoundsValid(self.step, self.player.position) then
            self.turn += 1
            updateGameObjectSteps(self.player, self.lasers, self.step, self.turn)
        end
    end
end

function Level:update()
    Player.super.update(self)
    self:setStep()
end
