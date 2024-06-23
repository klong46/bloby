import "constants"

class('MenuBackground').extends(SLIB)

local MENU_IMAGES <const> = {
    GFX.image.new('img/menu/menu_background_1'),
    GFX.image.new('img/menu/menu_background_2'),
    GFX.image.new('img/menu/menu_background_3')
}

local POSITION = {X = 200, Y = 120}

function MenuBackground:init()
    MenuBackground.super.init(self)
    self:setImage(MENU_IMAGES[1])
    self:moveTo(POSITION.X, POSITION.Y)
    self:add()
end

function MenuBackground:moveCursor(selectedBox)
    self:setImage(MENU_IMAGES[selectedBox])
end
