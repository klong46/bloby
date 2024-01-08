import "CoreLibs/sprites"
import "constants"

local image = GFX.image.new('img/start_button')

class('StartButton').extends(SLIB)

function StartButton:init()
    StartButton.super.init(self)
    self:setImage(image:scaledImage(1.5))
    self:moveTo(140, 160)
    self:setZIndex(6)
    self:add()
end

function StartButton:highlight()
    self:setImage(image:scaledImage(1.5))
end

function StartButton:unhighlight()
    self:setImage(image:scaledImage(1))
end

