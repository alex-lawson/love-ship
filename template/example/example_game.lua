require 'example/animation_configs'

Game = class()

function Game:init()
    MainCamera:set_center(vec2())
    self.cam_zoom = 1.0

    self.ball = Animation(animation_configs.ball)

    local tile_set = TileSet({
        source_image = "example/tiles.png",
        tile_size = {16, 16}
    })

    local map_data = MapData("example/map_data.txt")

    self.tile_map = TileMap(tile_set, map_data)
    self.tile_map:set_position(self.tile_map:size() * -0.5)

    self.ball_pos = vec2()
    self.ball_speed = vec2()
    self.ball_max_speed = 500
    self.ball_accel = 500
    self.ball_friction = 20

    self.ball_radius = 8
    self.collide_offsets = {
        west = vec2(-self.ball_radius, 0),
        east = vec2(self.ball_radius, 0),
        north = vec2(0, self.ball_radius),
        south = vec2(0, -self.ball_radius)
    }
end

function Game:update(dt)
    -- apply friction
    self.ball_speed = approach_vec2(self.ball_speed, vec2(), self.ball_friction, dt)

    -- apply controls
    local tar_speed = vec2()
    if love.keyboard.isDown("d") then
        tar_speed[1] = tar_speed[1] + self.ball_max_speed
    end
    if love.keyboard.isDown("a") then
        tar_speed[1] = tar_speed[1] - self.ball_max_speed
    end
    if love.keyboard.isDown("s") then
        tar_speed[2] = tar_speed[2] + self.ball_max_speed
    end
    if love.keyboard.isDown("w") then
        tar_speed[2] = tar_speed[2] - self.ball_max_speed
    end
    self.ball_speed = approach_vec2(self.ball_speed, tar_speed, self.ball_accel, dt)

    -- move ball
    self.ball_pos = self.ball_pos + self.ball_speed * dt

    -- handle collision
    local test_west = self.ball_pos + self.collide_offsets.west
    local test_east = self.ball_pos + self.collide_offsets.east
    if self.tile_map:tile_at(test_west) == 1 or self.tile_map:tile_at(test_east) == 1 then
        self.ball_pos[1] = self.ball_pos[1] - self.ball_speed[1] * dt
        MainCamera:set_center(MainCamera.view_center + self.ball_speed * 0.05)
        self.ball_speed[1] = -self.ball_speed[1]
    end

    local test_north = self.ball_pos + self.collide_offsets.north
    local test_south = self.ball_pos + self.collide_offsets.south
    if self.tile_map:tile_at(test_north) == 1 or self.tile_map:tile_at(test_south) == 1 then
        self.ball_pos[2] = self.ball_pos[2] - self.ball_speed[2] * dt
        MainCamera:set_center(MainCamera.view_center + self.ball_speed * 0.05)
        self.ball_speed[2] = -self.ball_speed[2]
    end

    -- update animation
    self.ball:set_position(self.ball_pos)
    self.ball:update(dt)

    -- lerp camera
    MainCamera:set_center(lerp_vec2(0.25, MainCamera.view_center, self.ball_pos))
end

function Game:render()
    self.tile_map:draw()

    self.ball:draw()
end

function Game:mouse_pressed(pos, button)
    if button == 1 then
        if self.ball.state_name == "idle_r" then
            self.ball:set_state("r_to_y")
        elseif self.ball.state_name == "idle_y" then
            self.ball:set_state("y_to_r")
        end
    elseif button == 2 then
        if self.ball.state_name == "idle_r" then
            self.ball:set_state("spin_r")
        elseif self.ball.state_name == "idle_y" then
            self.ball:set_state("spin_y")
        end
    end
end

function Game:mouse_released(pos, button)
    if button == 2 then
        if self.ball.state_name == "spin_r" then
            self.ball:set_state("idle_r")
        elseif self.ball.state_name == "spin_y" then
            self.ball:set_state("idle_y")
        end
    end
end

function Game:mouse_wheel_moved(x, y)
    self.cam_zoom = self.cam_zoom + (0.2 * y)
    MainCamera:set_scale(vec2(self.cam_zoom, self.cam_zoom))
end

function Game:key_pressed(key)

end

function Game:key_released(key)

end
