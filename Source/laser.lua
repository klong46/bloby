import "CoreLibs/sprites"
import "gameObject"

local PD <const> = playdate
local GFX <const> = PD.graphics

class('Laser').extends(GameObject)

local imagePath = 'img/laser/laser_'

function Laser:init(position, grid, direction)
    Laser.super.init(self)
    self.origin = position
    self.direction = direction
    self.length = self:setLength(grid)
    self:setImage(GFX.image.new(imagePath..self.length))
    self:setCenter(0.06, 0.5)
    if self.direction == 'right' then
        self:moveTo((self.origin.x * TileSize), (self.origin.y * TileSize) - 10)
    elseif self.direction == 'left' then
        self:moveTo((self.origin.x * TileSize) - self.width - 3, (self.origin.y * TileSize) - 10)
    end
    self:add()
end

function Laser:setVisible(turn)
    if (turn+1) % 2 == 0 then
        self:remove()
    else
        self:add()
    end
end

function Laser:setLength(grid)
    if (self.direction == 'up') then

    elseif (self.direction == 'down') then

    elseif (self.direction == 'left') then
        for i=1,TilesPerRow do
            if grid[(self.origin.y-1)*TilesPerRow+(self.origin.x-i)] == 1 then
                return i-1
            end
        end
    elseif (self.direction == 'right') then
        for i=1,TilesPerRow do
            if grid[(self.origin.y-1)*TilesPerRow+(self.origin.x+i)] == 1 then
                return i-1
            end
        end
    end
end
