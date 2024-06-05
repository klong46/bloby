import "staticObject"
import "constants"

class('Wall').extends(StaticObject)

local blank_wall = GFX.image.new('img/walls/wall_0')
local ROTATIONS = {
    90,
    180,
    -90
}

local images = {
    GFX.image.new('img/walls/wall_1'),
    GFX.image.new('img/walls/wall_2'),
    GFX.image.new('img/walls/wall_3'),
    GFX.image.new('img/walls/wall_4'),
    GFX.image.new('img/walls/wall_5'),
    GFX.image.new('img/walls/wall_6'),
    GFX.image.new('img/walls/wall_7'),
    GFX.image.new('img/walls/wall_8'),
}

function Wall:init(position, surrounded)
    Wall.super.init(self, blank_wall, position)
    self.surrounded = surrounded
    self:setImage(self:getImage(position))
    self:setZIndex(1)
    self:add()
end

function Wall:getImage(position)
    math.randomseed(position.x, position.y)
    local imgNum = math.random(#images)
    if self.surrounded then
        local rotation = ROTATIONS[math.random(3)]
        return images[imgNum]:blendWithImage(blank_wall, 0.35, GFX.image.kDitherTypeBurkes):rotatedImage(rotation)
    end
    return blank_wall
end