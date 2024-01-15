import "CoreLibs/sprites"
import "constants"
import "levelSelectTile"

local NUM_COLS = 5
local NUM_ROWS = 3

local function getLevelNum(x, y)
    return ((y-1)*NUM_COLS)+x
end

local NUM_LEVELS = getLevelNum(NUM_COLS, NUM_ROWS)

class('LevelSelect').extends(SLIB)

function LevelSelect:init()
    LevelSelect.super.init(self)
    self.cursorPos = PD.geometry.point.new(1,1)
    self.previousSelected = PD.geometry.point.new(1,1)
    self.tiles = {}
    self:addLevelTiles()
    self:add()
end

function LevelSelect:addLevelTiles()
    local selected = true
    for y = 1, NUM_ROWS, 1 do
        for x = 1, NUM_COLS, 1 do
            table.insert(self.tiles, LevelSelectTile(x, y, getLevelNum(x, y), selected))
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
    if getLevelNum(self.cursorPos.x, self.cursorPos.y) < NUM_LEVELS then
        self:setPreviousSelected()
        self.cursorPos.x += 1
        self:updateSelectTiles()
    end
end

function LevelSelect:cursorDown()
    if self.cursorPos.y < NUM_ROWS then
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
    -- print(self.previousSelected.x, self.previousSelected.y)
    self.tiles[getLevelNum(self.previousSelected.x, self.previousSelected.y)]:unselect()
    self.tiles[getLevelNum(self.cursorPos.x, self.cursorPos.y)]:select()
end
