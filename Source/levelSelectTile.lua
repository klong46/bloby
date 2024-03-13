import "CoreLibs/sprites"
import "constants"
import "levelSelectNumber"

local TILE_IMAGES <const> = {
    GFX.image.new('img/level_tile/one_star'),
    GFX.image.new('img/level_tile/two_star'),
    GFX.image.new('img/level_tile/three_star'),
    GFX.image.new('img/level_tile/locked_level'),
    GFX.image.new('img/level_tile/unfinished_level'),
    GFX.image.new('img/level_tile/blank_tile'),
}

local WIDTH = 80

class('LevelSelectTile').extends(SLIB)

function LevelSelectTile:init(x, y, levelNum, selected, locked, score)
    LevelSelectTile.super.init(self)
    self:setSize(200, 22)
    if not locked then
        if score then
            self.image = TILE_IMAGES[score]
            self:setImage(self.image)
        else
            self.image = TILE_IMAGES[5]
        end
        if not selected then
            self:setImage(self.image:fadedImage(0.5, GFX.image.kDitherTypeBayer8x8))
        end
    else
        self:setImage(TILE_IMAGES[4])

    end
    self:moveTo(x*WIDTH-40, y*WIDTH-40)
    if levelNum > TOTAL_LEVELS then
        self:setImage(TILE_IMAGES[6])
    else
        self.numberLabel = LevelSelectNumber(x, y, levelNum, selected)
    end
    self:add()
end

function LevelSelectTile:unselect()
    self:setImage(self.image:fadedImage(0.5, GFX.image.kDitherTypeBayer8x8))
    self.numberLabel:unselect()
end

function LevelSelectTile:select()
    self:setImage(self.image)
    self.numberLabel:select()
end
