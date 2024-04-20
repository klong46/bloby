import "eyelid"

class('GameWinScreen').extends(SLIB)

local GW_IMAGES <const> = {
    GFX.image.new('img/game_win/gw_up'),
    GFX.image.new('img/game_win/gw_down'),
    GFX.image.new('img/game_win/gw_left'),
    GFX.image.new('img/game_win/gw_right')
}

local EYES_CLOSED_Y_POS = 42

function GameWinScreen:init()
    GameWinScreen.super.init(self)
    self:moveTo(200,120)
    self:setImage(GW_IMAGES[4])
    self.topEyelid = Eyelid(200, -15)
    self.bottomEyelid = Eyelid(200, 200)
    self:add()
end

function GameWinScreen:up()
    self:setImage(GW_IMAGES[1])
end

function GameWinScreen:down()
    self:setImage(GW_IMAGES[2])
end

function GameWinScreen:left()
    self:setImage(GW_IMAGES[3])
end

function GameWinScreen:right()
    self:setImage(GW_IMAGES[4])
end

function GameWinScreen:moveEyelids()
    self.topEyelid:moveTo(self.topEyelid.x, self.topEyelid.y + (CrankTicks * 2))
    self.bottomEyelid:moveTo(self.bottomEyelid.x, self.bottomEyelid.y - (CrankTicks * 2))
    print(self.topEyelid.y)
end

function GameWinScreen:update()
    GameWinScreen.super.update(self)
    if CrankTicks < 0 then
        if self.topEyelid.y > -20 then
            self:moveEyelids()
        end
    elseif CrankTicks > 0 then
        self:moveEyelids()
    end
    if self.topEyelid.y >= EYES_CLOSED_Y_POS then
        ReturnToMenu()
    end
end