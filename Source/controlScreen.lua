import "CoreLibs/sprites"

class('ControlScreen').extends(SLIB)

local control_screen_1 = GFX.image.new('img/controls_1')
local control_screen_2 = GFX.image.new('img/controls_2')

function ControlScreen:init()
    ControlScreen.super.init(self)
    OnControlScreen = true
    self.screen = 1
    SLIB.removeAll()
    self:setImage(control_screen_1)
    self:moveTo(200, 120)
    ContinueButton()
    self:add()
end

function ControlScreen:next()
    if self.screen == 1 then
        self:setImage(control_screen_2)
        self.screen = 2
    elseif self.screen == 2 then
        OnControlScreen = false
        StartGame(1)
    end
end

function ControlScreen:back()
    if self.screen == 1 then
        OnControlScreen = false
        ReturnToMenu()
    elseif self.screen == 2 then
        self:setImage(control_screen_1)
        self.screen = 1
    end
end