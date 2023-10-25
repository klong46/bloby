import "CoreLibs/sprites"
import "constants"

class('GameObject').extends(SLIB)

function GameObject:init(image)
    GameObject.super.init(self)
    self:setImage(image)
    self:add()
end
