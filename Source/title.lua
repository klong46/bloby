import "CoreLibs/sprites"
import "constants"

local image = GFX.image.new('img/title')

class('Title').extends(SLIB)

function Title:init()
    Title.super.init(self)
    self:setImage(image:scaledImage(2))
    self:moveTo(200, 80)
    self:setZIndex(6)
    self:add()
end

