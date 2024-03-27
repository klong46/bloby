import "CoreLibs/sprites"
import "constants"

local MENU_IMAGES <const> = {
    GFX.image.new('img/menu/menu_background_1'),
    GFX.image.new('img/menu/menu_background_2'),
    GFX.image.new('img/menu/menu_background_3')
}

class('MenuBackground').extends(SLIB)

function MenuBackground:init()
    MenuBackground.super.init(self)
    self:setImage(MENU_IMAGES[1])
    self:moveTo(200, 120)
    self:add()
end

function MenuBackground:moveCursor(selectedBox)
    self:setImage(MENU_IMAGES[selectedBox])
end
