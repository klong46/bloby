import "CoreLibs/sprites"
import "staticObject"
import "constants"

class('Ladder').extends(StaticObject)

local animationTable = GFX.imagetable.new('img/ladder_animation')
local ANIMATION_SPEED = 120

function Ladder:init(position)
    Ladder.super.init(self, image, position)
    self.animation = GFX.animation.loop.new(ANIMATION_SPEED, animationTable, true)
end

function Ladder:update()
    Ladder.super.update(self)
    self:setImage(self.animation:image())
end
