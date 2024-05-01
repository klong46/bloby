import "constants"
import "levelSelectNumber"
import "blankTile"

class('LevelSelectTile').extends(SLIB)

local TILE_IMAGES <const> = {
    GFX.image.new('img/level_tile/one_star'),
    GFX.image.new('img/level_tile/two_star'),
    GFX.image.new('img/level_tile/three_star'),
    GFX.image.new('img/level_tile/locked_level'),
    GFX.image.new('img/level_tile/unfinished_level'),
    GFX.image.new('img/level_tile/blank_tile'),
}

local WIDTH = 80
local SIZE = {WIDTH = 200, HEIGHT = 22}
local TILE_OFFSET = 40

function LevelSelectTile:init(x, y, levelNum, selected, locked, score)
    LevelSelectTile.super.init(self)
    self.background = BlankTile(x, y)
    self:setSize(SIZE.WIDTH, SIZE.HEIGHT)
    if not locked then
        if score then
            self.image = TILE_IMAGES[score]
            self:setImage(self.image)
        else
            self.image = TILE_IMAGES[5]
        end
        if not selected then
            self:setImage(self.image)
        end
    else
        self:setImage(TILE_IMAGES[4])
    end
    self:moveTo(x*WIDTH-TILE_OFFSET, y*WIDTH-TILE_OFFSET)
    if levelNum > BONUS_LEVEL then
        self:setImage(TILE_IMAGES[6])
    end
    self.numberLabel = LevelSelectNumber(x, y, levelNum, selected)
    self:add()
end

function LevelSelectTile:unselect()
    self.background:setVisible(true)
    self.numberLabel:unselect()
end

function LevelSelectTile:select()
    self:setImage(self.image)
    self.background:setVisible(false)
    self.numberLabel:select()
end
