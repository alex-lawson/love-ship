local function build_tileset_quads(source_tex, tile_size)
    local tw, th = source_tex:getDimensions()

    local quads = {}

    local quad_count = 0
    local x, y = 0, 0
    while y < th do
        while x < tw do
            table.insert(quads, love.graphics.newQuad(x, y, tile_size[1], tile_size[2], tw, th))
            quad_count = quad_count + 1
            x = x + tile_size[1]
        end
        x = 0
        y = y + tile_size[2]
    end
    return quads, quad_count
end

TileSet = class()

function TileSet:init(conf)
    self.source_tex = load_image(conf.source_image)
    self.tile_size = vec2(conf.tile_size)
    self.tile_quads, self.tile_count = build_tileset_quads(self.source_tex, self.tile_size)
end

MapData = class()

function MapData:init(data, map_size)
    self.data, self.map_size = data, map_size
end

function MapData:get(x, y)
    return self.data[(y - 1) * self.map_size[1] + x]
end

function MapData.from_txt_file(source_file)
    local size_x
    local size_y = 0
    local map_data = {}

    -- bare minimum; lots of ways this can mysteriously fail for now
    for line in io.lines(source_file) do
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
    self.map_data = map_data
end

function TileMap:draw()
    for x = 1, self.map_data.map_size[1] do
        for y = 1, self.map_data.map_size[2] do
            local draw_pos = self:tile_position(x, y)
            local tile_index = self.map_data:get(x, y)
            if tile_index > 0 then
                love.graphics.draw(self.tile_set.source_tex, self.tile_set.tile_quads[tile_index], draw_pos[1], draw_pos[2])
            end
        end
    end
end

function TileMap:set_position(pos)
    self.position = pos
end

function TileMap:size()
    return self.tile_set.tile_size * self.map_data.map_size
end

function TileMap:bounds()
    return rect(self.position, self.position + self:size())
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
