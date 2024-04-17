class('DragonScale').extends(DynamicObject)

local DRAGON_SCALE_IMAGE = GFX.image.new('img/dragon/dragon_scale')

function DragonScale:init(position, direction, grid)
    DragonScale.super.init(self, DRAGON_SCALE_IMAGE, position, direction, grid)
    self:add()
end