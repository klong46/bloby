import "constants"

class('Transition').extends(SLIB)

local animationTable = GFX.imagetable.new('img/transition_animation')
local FRAME_RATE = 25

function Transition:init(destination, levelNum)
    Transition.super.init(self)
    self.transitionAnimation = GFX.animation.loop.new(FRAME_RATE, animationTable, false)
    self.destination = destination
    self.levelNum = levelNum
    self:setZIndex(13)
    self:moveTo(200, 120)
    InTransition = true
    self.halfway = false
    self:add()
end

function Transition:clearScreen()
    local sprites = GFX.sprite.getAllSprites()
    for i = (#sprites-1), 1, -1 do
        sprites[i]:remove()
    end
end

function Transition:update()
    Transition.super.update(self)
    self:setImage(self.transitionAnimation:image())
    if self.transitionAnimation.frame > 10 and not self.halfway then
        self:clearScreen()
        if self.destination == "level_select" then
            GoToLevelSelect()
        elseif self.destination == "start_game" then
            StartGame(self.levelNum)
        elseif self.destination == "credits" then
            GoToCredits()
        elseif self.destination == "menu" then
            ReturnToMenu()
        elseif self.destination == "tutorial" then
            StartTutorial()
        end
        self.halfway = true
    end
    if not self.transitionAnimation:isValid() then
        InTransition = false
        self:remove()
    end
end