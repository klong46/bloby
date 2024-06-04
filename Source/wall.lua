import "staticObject"
import "constants"

class('Wall').extends(StaticObject)

local WALL_FREQ = 20

local blank_wall = GFX.image.new('img/walls/wall_0')

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

function Wall:init(position)
    Wall.super.init(self, images[1], position)
    self:setImage(self:getImage(position))
    self:setZIndex(1)
    self:add()
end

function Wall:getImage(position)
    math.randomseed(position.x, position.y)
    local imgNum = math.random(#images + WALL_FREQ)
    if imgNum <= #images then
        return images[imgNum]
    end
    return blank_wall

end