local function build_tileset_quads(source_tex, tile_size, tile_padding)
    local tw, th = source_tex:getDimensions()

    local grid_size = tile_size + tile_padding * 2

    local quads = {}

    local quad_count = 0
    local x, y = 0, 0
    while y < th do
        while x < tw do
            table.insert(quads, love.graphics.newQuad(x + tile_padding[1], y + tile_padding[2], tile_size[1], tile_size[2], tw, th))
            quad_count = quad_count + 1
            x = x + grid_size[1]
        end
        x = 0
        y = y + grid_size[2]
    end
    return quads, quad_count
end

TileSet = class()

function TileSet:init(conf)
    self.source_tex = load_image(conf.source_image)
    self.tile_size = vec2(conf.tile_size)
    self.tile_padding = vec2(conf.tile_padding)
    self.tile_quads, self.tile_count = build_tileset_quads(self.source_tex, self.tile_size, self.tile_padding)
end

MapData = class()

function MapData:init(data, map_size)
    self.data, self.map_size = data, map_size
end

function MapData:in_map(x, y)
    return x > 0 and y > 0 and x <= self.map_size[1] and y <= self.map_size[2]
end

function MapData:get(x, y)
    return self.data[(y - 1) * self.map_size[1] + x]
end

function MapData:set(x, y, v)
    self.data[(y - 1) * self.map_size[1] + x] = v
end

function MapData.from_txt_file(source_file)
    local size_x
    local size_y = 0
    local map_data = {}

    -- bare minimum; lots of ways this can mysteriously fail for now
    for line in love.filesystem.lines(source_file) do
        size_x = size_x or #line
        size_y = size_y + 1
        for i = 1, #line do
            table.insert(map_data, tonumber(line:sub(i,i)))
        end
    end

    return MapData(map_data, vec2(size_x, size_y))
end

function MapData.with_size(map_size)
    local map_data = {}

    for i = 1, map_size[1] * map_size[2] do
        table.insert(map_data, 0)
    end

    return MapData(map_data, map_size)
end

TileMap = class()

function TileMap:init(tile_set, map_data)
    self.tile_set = tile_set
    self.position = vec2()

    self:set_map_data(map_data)
end

function TileMap:draw()
    if self.cache_dirty then
        self:build_sprite_batch()
        self.cache_dirty = false
    end

    love.graphics.draw(self.sprite_batch)
end

function TileMap:build_sprite_batch()
    self.sprite_batch:clear()
    for x = 1, self.map_data.map_size[1] do
        for y = 1, self.map_data.map_size[2] do
            local tile_index = self.map_data:get(x, y)
            if tile_index > 0 then
                local draw_pos = self:tile_position(x, y)
                self.sprite_batch:add(self.tile_set.tile_quads[tile_index], unpack(draw_pos))
            end
        end
    end
end

function TileMap:set_map_data(map_data)
    self.map_data = map_data
    self.sprite_batch = love.graphics.newSpriteBatch(self.tile_set.source_tex, self.map_data.map_size[1] * self.map_data.map_size[2])
    self.cache_dirty = true
end

function TileMap:set_position(pos)
    self.position = pos
    self.cache_dirty = true
end

function TileMap:size()
    return self.tile_set.tile_size * self.map_data.map_size
end

function TileMap:bounds()
    return rect(self.position, self.position + self:size())
end

function TileMap:non_empty_bounds()
    local bounds
    for x = 1, self.map_data.map_size[1] do
        for y = 1, self.map_data.map_size[2] do
            if self.map_data:get(x, y) > 0 then
                if bounds then
                    bounds = bounds:combine({x - 1, y - 1, x, y})
                else
                    bounds = rect(x - 1, y - 1, x, y)
                end
            end
        end
    end

    if bounds then
        bounds = bounds * self.tile_set.tile_size + self.position
        return bounds
    end
end

function TileMap:tile_at(world_pos)
    if self:bounds():contains(world_pos) then
        local transformed = (world_pos - self.position) / self.tile_set.tile_size
        local x = math.floor(transformed[1]) + 1
        local y = math.floor(transformed[2]) + 1
        local v = self.map_data:get(x, y)
        return v, x, y
    end
end

function TileMap:tile_position(x, y)
    return self.position + vec2(x - 1, y - 1) * self.tile_set.tile_size
end

function TileMap:tile_center(x, y)
    return self:tile_position(x, y) + self.tile_set.tile_size * 0.5
end

function TileMap:set(x, y, v)
    if self.map_data:in_map(x, y) then
        self.map_data:set(x, y, v)
        self.cache_dirty = true
        return true
    end
end

function TileMap:get(x, y)
    if self.map_data:in_map(x, y) then
        return self.map_data:get(x, y)
    end
end
