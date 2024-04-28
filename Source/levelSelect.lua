import "CoreLibs/sprites"
import "constants"
import "levelSelectTile"

local NUM_COLS = 5
local NUM_ROWS = 7
local ROWS_ON_SCREEN = 3


local function getLevelNum(x, y)
    return math.floor(((y-1)*NUM_COLS)+x)
end

local currentLevel = 1
local scrollDown = true
local scrollQueued = false

class('LevelSelect').extends(SLIB)

function LevelSelect:init(startingLevel, scores)
    LevelSelect.super.init(self)
    if startingLevel then
        currentLevel = startingLevel
    end
    self.scores = scores
    self.cursorPos = PD.geometry.point.new(1,1)
    self.previousSelected = PD.geometry.point.new(1,1)
    self.tiles = {}
    self.scrollAnimator = nil
    self:addLevelTiles()
    self.tiles[getLevelNum(self.cursorPos.x, self.cursorPos.y)]:select()
    self.offset = 0
    self:add()
end

function LevelSelect:addLevelTiles()
    local selected = true
    local locked = false
    local levelNum = 1
    for y = 1, NUM_ROWS, 1 do
        for x = 1, NUM_COLS, 1 do
            levelNum = getLevelNum(x, y)
            if levelNum > currentLevel then
                locked = true
            end
            table.insert(self.tiles, LevelSelectTile(x, y, levelNum, selected, locked, self.scores[levelNum]))
            selected = false
        end
    end
end

function LevelSelect:cursorLeft()
    if getLevelNum(self.cursorPos.x, self.cursorPos.y) > 1 then
        self:setPreviousSelected()
        if self.cursorPos.x % NUM_COLS == 1 then
            self.cursorPos.y -= 1
            self.cursorPos.x = NUM_COLS
            self:checkScrollUp()
        else
            self.cursorPos.x -= 1
        end
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorRight()
    if getLevelNum(self.cursorPos.x, self.cursorPos.y) < BONUS_LEVEL and
       getLevelNum(self.cursorPos.x, self.cursorPos.y) < currentLevel then
        self:setPreviousSelected()
        if self.cursorPos.x % NUM_COLS == 0 then
            self.cursorPos.y += 1
            self.cursorPos.x = 1
            self:checkScrollDown()
        else
            self.cursorPos.x += 1
        end
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorDown()
    if self.cursorPos.y < NUM_ROWS and
       getLevelNum(self.cursorPos.x, self.cursorPos.y + 1) <= currentLevel then
        self:setPreviousSelected()
        self.cursorPos.y += 1
        self:updateSelectTiles()
        self:checkScrollDown()
    end
end

function LevelSelect:cursorUp()
    if self.cursorPos.y > 1 then
        self:setPreviousSelected()
        self.cursorPos.y -= 1
        self:updateSelectTiles()
        self:checkScrollUp()
    end
end

function LevelSelect:checkScrollDown()
    if self.offset < NUM_ROWS-ROWS_ON_SCREEN then
        self:scrollDown()
    end
end

function LevelSelect:checkScrollUp()
    if self.offset > 0 then
        self:scrollUp()
    end
end

function LevelSelect:setPreviousSelected()
    self.previousSelected.x = self.cursorPos.x
    self.previousSelected.y = self.cursorPos.y
end

function LevelSelect:updateSelectTiles()
    self.tiles[getLevelNum(self.previousSelected.x, self.previousSelected.y)]:unselect()
    self.tiles[getLevelNum(self.cursorPos.x, self.cursorPos.y)]:select()
end

function LevelSelect:select()
    if currentLevel == 1 and #self.scores == 0 then
        Tutorial = ControlScreen()
    else
        StartGame(getLevelNum(self.cursorPos.x, self.cursorPos.y))
    end
    self:remove()
end

function LevelSelect:scrollDown()
    scrollDown = true
    self.offset += 1
    self:startAnimator()
end

function LevelSelect:scrollUp()
    scrollDown = false
    self.offset -= 1
    self:startAnimator()
end

function LevelSelect:startAnimator()
    if not self.scrollAnimator then
        self.scrollAnimator = GFX.animator.new(500, 0, 80, playdate.easingFunctions.outCubic)
    else
        if self.scrollAnimator:ended() then
            self.scrollAnimator:reset()
        else
            scrollQueued = true
        end
    end
end

function LevelSelect:update()
    LevelSelect.super.update(self)
    if CrankTicks > 0 then
        self:cursorRight()
    elseif CrankTicks < 0 then
        self:cursorLeft()
    end

    if scrollQueued then
        self.scrollAnimator:reset()
        scrollQueued = false
    end
    if self.scrollAnimator and (not self.scrollAnimator:ended()) then
        for y = 1, NUM_ROWS, 1 do
            for x = 1, NUM_COLS, 1 do
                local number = self.tiles[getLevelNum(x,y)].numberLabel
                local yPos
                if scrollDown then
                    yPos = ((y-self.offset+1)*80-55) - self.scrollAnimator:currentValue()
                else
                    yPos = ((y-self.offset-1)*80-55) + self.scrollAnimator:currentValue()
                end
                number:moveTo(number.x, yPos)
                local tile = self.tiles[getLevelNum(x,y)]
                tile:moveTo(tile.x, yPos+15)
                tile.background:moveTo(tile.x, yPos+15)
            end
        end
    end
end