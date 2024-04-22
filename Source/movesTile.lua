import "CoreLibs/sprites"
import "staticObject"
import "constants"

local font = GFX.font.new("fonts/Roobert-9-Mono-Condensed")

class('MovesTile').extends(SLIB)

function MovesTile:init(position)
    MovesTile.super.init(self)
    self:setSize(25, 20)
    self:moveTo((position.x * TILE_SIZE) - 3, (position.y * TILE_SIZE) - 7)
    self:setZIndex(2)
    self:add()
end

function MovesTile:update()
    MovesTile.super.update(self)
    self:markDirty()
end

function MovesTile:draw()
    GFX.setImageDrawMode(GFX.kDrawModeInverted)
    GFX.setFont(font)
    GFX.drawText(""..(Turn-1).."", 0, 0)
end