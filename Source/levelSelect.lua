import "CoreLibs/sprites"
import "constants"
import "levelSelectTile"

local NUM_COLS = 5
local NUM_ROWS = 3

local function getLevelNum(x, y)
    return math.floor(((y-1)*NUM_COLS)+x)
end

local NUM_LEVELS = getLevelNum(NUM_COLS, NUM_ROWS)
local currentLevel = 1

class('LevelSelect').extends(SLIB)

function LevelSelect:init(startingLevel)
    LevelSelect.super.init(self)
    currentLevel = startingLevel
    self.cursorPos = PD.geometry.point.new(1,1)
    self.previousSelected = PD.geometry.point.new(1,1)
    self.tiles = {}
    self:addLevelTiles()
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
            table.insert(self.tiles, LevelSelectTile(x, y, levelNum, selected, locked))
            selected = false
        end
    end
end

function LevelSelect:cursorLeft()
    if getLevelNum(self.cursorPos.x, self.cursorPos.y) > 1 then
        self:setPreviousSelected()
        self.cursorPos.x -= 1
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorRight()
    if getLevelNum(self.cursorPos.x, self.cursorPos.y) < NUM_LEVELS and
       getLevelNum(self.cursorPos.x, self.cursorPos.y) < currentLevel then
        self:setPreviousSelected()
        self.cursorPos.x += 1
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorDown()
    if self.cursorPos.y < NUM_ROWS and
       getLevelNum(self.cursorPos.x, self.cursorPos.y + 1) < currentLevel then
        self:setPreviousSelected()
        self.cursorPos.y += 1
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorUp()
    if self.cursorPos.y > 1 then
        self:setPreviousSelected()
        self.cursorPos.y -= 1
        self:updateSelectTiles()
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
    StartGame(getLevelNum(self.cursorPos.x, self.cursorPos.y))
    self:remove()
end