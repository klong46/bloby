import "constants"

class('MenuSelect').extends(SLIB)

local MENU_IMAGES <const> = {
    GFX.image.new('img/menu/menu_select_1'),
    GFX.image.new('img/menu/menu_select_2'),
    GFX.image.new('img/menu/menu_select_3')
}


local POSITION = {X = 330, Y = 125}

function MenuSelect:init()
    MenuSelect.super.init(self)
    self:setImage(MENU_IMAGES[1])
    self:moveTo(POSITION.X, POSITION.Y)
    self:setZIndex(6)
    self:add()
end

function MenuSelect:moveCursor(selectedBox)
    self:setImage(MENU_IMAGES[selectedBox])
end

