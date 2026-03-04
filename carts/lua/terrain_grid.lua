grid = {}


function create_empty_grid(width, height)
    local grid = {}
    for y = 1, height do
        local row = {}
        for x = 1, width do
            row[x] = 0
        end
        grid[y] = row
    end
    return grid
end

function tset(x, y, id)
    trace(("tset(%02d, %02d, %3d)"):format(x, y, id))
    grid[y + 1][x + 1] = id
    local mx, my = 2*x, GROUND_Y + 2*y
    mset(mx    , my    , id       )
    mset(mx + 1, my    , id + 0x01)
    mset(mx    , my + 1, id + 0x10)
    mset(mx + 1, my + 1, id + 0x11)
end


function terrain_generate()
    grid = create_empty_grid(TERRAIN_WIDTH, TERRAIN_HEIGHT)
    for y = 0, TERRAIN_HEIGHT - 1 do
        for x = 0, TERRAIN_WIDTH - 1 do
            tset(x, y, TILE_DIRT_1)
        end
    end

    for i = 1, 3 do
        local x, y = math.random(1, 9), math.random(1, 5)
        tset(x, y, TILE_DINO_SMOL_1)
    end
end