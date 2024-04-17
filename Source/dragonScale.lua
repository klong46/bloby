class('DragonScale').extends(DynamicObject)

local DRAGON_SCALE_IMAGE = GFX.image.new('img/dragon/scale')

function DragonScale:init(position, direction, grid)
    DragonScale.super.init(self, DRAGON_SCALE_IMAGE, position, direction, grid)
    self:add()
end

function DragonScale:moveBack()
    if self:hasPastMoves() then
        self.lastDirection = self.pastMoves[#self.pastMoves].direction
        local lastMove = table.remove(self.pastMoves)
        self.position = lastMove.position
        self.isBlocked = lastMove.isBlocked
        self.direction = lastMove.direction
    end
end