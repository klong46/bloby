import "CoreLibs/sprites"
import "constants"
import "levelSelectNumber"

local TILE_IMAGES <const> = {
    GFX.image.new('img/level_tile/one_star'),
    GFX.image.new('img/level_tile/two_star'),
    GFX.image.new('img/level_tile/three_star'),
    GFX.image.new('img/level_tile/locked_level'),
}

local WIDTH = 80

class('LevelSelectTile').extends(SLIB)

function LevelSelectTile:init(x, y, levelNum, selected, locked)
    LevelSelectTile.super.init(self)
    self:setSize(200, 22)
    self:setZIndex(6)
    if not locked then
        self.image = TILE_IMAGES[3]
        self:setImage(self.image)
        if not selected then
            self:setImage(self.image:fadedImage(0.5, GFX.image.kDitherTypeBayer8x8))
        end
    else
        self:setImage(TILE_IMAGES[4])
    end
    self:moveTo(x*WIDTH-40, y*WIDTH-40)
    self.numberLabel = LevelSelectNumber(x, y, levelNum, selected)
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
