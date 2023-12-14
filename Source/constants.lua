PD = playdate
GFX = PD.graphics
SLIB = GFX.sprite

DIRECTIONS = {UP = -1, DOWN = 1, LEFT = -2, RIGHT = 2}
CRANK_SPEED = 6
TOTAL_LEVELS = 11
TEST_LEVEL = 1
DEFAULT_PLAYER_DIRECTION = DIRECTIONS.DOWN
DEFAULT_LASER_CADENCE = 2
DEFAULT_LASER_OFFSET = 0
DEFAULT_GUARD_DIRECTION = DIRECTIONS.DOWN
DEFAULT_MOUSE_DIRECTION = DIRECTIONS.DOWN
DEFAULT_MOUSE_DELAY = 2
FORWARD_STEP = 1
BACKWARD_STEP = -1

TILE_SIZE = 20
TILES_PER_ROW  = 20
TILES_PER_COLUMN = 12
TILE_SPRITE_OFFSET = 10

EMPTY_TILE  = 0
WALL_TILE = 1
RIGHT_LASER_TILE = 2
LEFT_LASER_TILE = 3
UP_LASER_TILE = 4
DOWN_LASER_TILE = 5
GUARD_TILE = 6
MOUSE_TILE = 7
LADDER_TILE = 8
PLAYER_TILE = 9
PLAYER_OBSTACLES = {WALL_TILE, RIGHT_LASER_TILE, LEFT_LASER_TILE, UP_LASER_TILE, DOWN_LASER_TILE}
GUARD_OBSTACLES =  {WALL_TILE, RIGHT_LASER_TILE, LEFT_LASER_TILE, UP_LASER_TILE, DOWN_LASER_TILE, LADDER_TILE}

function GetTile(x, y)
    return ((y-1)*TILES_PER_ROW)+x
end

function GetByDirection(optionsList, direction)
    if direction == DIRECTIONS.UP then
        return optionsList[1]
    elseif direction == DIRECTIONS.DOWN then
        return optionsList[2]
    elseif direction == DIRECTIONS.LEFT then
        return optionsList[3]
    elseif direction == DIRECTIONS.RIGHT then
        return optionsList[4]
    end
end

function PrintGrid(grid)
    print("NEW GRID")
    local text = ""
    for i, tile in ipairs(grid) do
        text = text .. tostring(tile)
        if (i % 20 == 0) then
            print(text)
            print()
            text = ""
        end
    end
end
