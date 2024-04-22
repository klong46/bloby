import "CoreLibs/sprites"
import "staticObject"
import "constants"

local font = GFX.font.new("fonts/Roobert-9-Mono-Condensed")

class('MovesTile').extends(SLIB)

function MovesTile:init(position)
    MovesTile.super.init(self)
    self:setSize(30, 20)
    self:moveTo((position.x * TILE_SIZE) - 1, (position.y * TILE_SIZE) - 7)
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
    local move = Turn-1
    if move > 999 then
        GFX.drawText("999+", 0, 0)
    else
        GFX.drawText(""..move.."", 0, 0)
    end
end