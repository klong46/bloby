import "CoreLibs/sprites"
import "constants"

local MENU_IMAGES <const> = {
    GFX.image.new('img/menu/menu_select_1'),
    GFX.image.new('img/menu/menu_select_2'),
    GFX.image.new('img/menu/menu_select_3')
}

class('MenuSelect').extends(SLIB)

function MenuSelect:init()
    MenuSelect.super.init(self)
    self:setImage(MENU_IMAGES[1])
    self:moveTo(330, 125)
    self:setZIndex(6)
    self:add()
end

function MenuSelect:moveCursor(selectedBox)
    self:setImage(MENU_IMAGES[selectedBox])
end

