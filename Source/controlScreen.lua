import "constants"

class('ControlScreen').extends(SLIB)

local SCREEN_1 = GFX.image.new('img/controls_1')
local SCREEN_2 = GFX.image.new('img/controls_2')
local POSITION = {X = 200, Y = 120}

function ControlScreen:init()
    ControlScreen.super.init(self)
    OnControlScreen = true
    self.screen = 1
    SLIB.removeAll()
    self:setImage(SCREEN_1)
    self:moveTo(POSITION.X, POSITION.Y)
    ContinueButton()
    self:add()
end

function ControlScreen:next()
    if self.screen == 1 then
        self:setImage(SCREEN_2)
        self.screen = 2
    elseif self.screen == 2 then
        OnControlScreen = false
        -- Start on first level
        StartGame(1)
    end
end

function ControlScreen:back()
    if self.screen == 1 then
        OnControlScreen = false
        ReturnToMenu()
    elseif self.screen == 2 then
        self:setImage(SCREEN_1)
        self.screen = 1
    end
end