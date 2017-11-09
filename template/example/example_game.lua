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

    local map_data = MapData.from_txt_file("example/map_data.txt")

    self.tile_map = TileMap(tile_set, map_data)
    self.tile_map:set_position(self.tile_map:size() * -0.5)

    self.ball_pos = vec2()
    self.ball_speed = vec2()
    self.ball_max_speed = 400
    self.ball_air_ctrl = 100
    self.ball_ground_ctrl = 300
    self.ball_friction = 20

    self.gravity = 200

    self.ball_radius = 8
    self.collide_offsets = {
        west = vec2(-self.ball_radius, 0),
        east = vec2(self.ball_radius, 0),
        north = vec2(0, self.ball_radius),
        south = vec2(0, -self.ball_radius)
    }
    self.bounce_factor = 0.7

    self.jump_velocity = 300
    self.jump_spin_rate = 4

    self.ball_spin_rate = 0
    self.ball_spin_decay = 2

    self.camera_impact_factor = 0.03
end

function Game:update(dt)
    self:update_ball(dt)

    -- lerp camera
    MainCamera:set_center(lerp_vec2(0.25, MainCamera.view_center, self.ball_pos))
end

function Game:update_ball(dt)
    -- apply gravity
    self.ball_speed[2] = self.ball_speed[2] + self.gravity * dt

    -- apply friction
    self.ball_speed = approach_vec2(self.ball_speed, vec2(), self.ball_friction, dt)

    -- apply horizontal controls
    local tar_h_speed = 0
    if love.keyboard.isDown("d") then
        tar_h_speed = tar_h_speed + self.ball_max_speed
    end
    if love.keyboard.isDown("a") then
        tar_h_speed = tar_h_speed - self.ball_max_speed
    end
    local ctrl_force = self:ball_on_ground() and self.ball_ground_ctrl or self.ball_air_ctrl
    self.ball_speed[1] = approach(self.ball_speed[1], tar_h_speed, ctrl_force, dt)

    -- move ball
    self.ball_pos = self.ball_pos + self.ball_speed * dt

    -- handle collision
    local test_west = self.ball_pos + self.collide_offsets.west
    local test_east = self.ball_pos + self.collide_offsets.east
    if self.tile_map:tile_at(test_west) == 1 or self.tile_map:tile_at(test_east) == 1 then
        print("bounced horizontally")
        self.ball_pos[1] = self.ball_pos[1] - self.ball_speed[1] * dt
        MainCamera:set_center(MainCamera.view_center + vec2(self.ball_speed[1] * self.camera_impact_factor, 0))
        self.ball_speed[1] = -self.ball_speed[1] * self.bounce_factor
    end

    local test_north = self.ball_pos + self.collide_offsets.north
    local test_south = self.ball_pos + self.collide_offsets.south
    if self.tile_map:tile_at(test_north) == 1 or self.tile_map:tile_at(test_south) == 1 then
        print("bounced vertically")
        self.ball_pos[2] = self.ball_pos[2] - self.ball_speed[2] * dt
        MainCamera:set_center(MainCamera.view_center + vec2(0, self.ball_speed[2] * self.camera_impact_factor))
        self.ball_speed[2] = -self.ball_speed[2] * self.bounce_factor
    end

    self.ball_spin_rate = math.max(0, self.ball_spin_rate - self.ball_spin_decay * dt)

    -- update animation
    self.ball:set_position(self.ball_pos)
    self.ball:set_rate(self.ball_spin_rate)
    self.ball:update(dt)
end

function Game:render()
    self.tile_map:draw()

    self.ball:draw()
end

function Game:mouse_pressed(pos, button)

end

function Game:mouse_released(pos, button)

end

function Game:mouse_wheel_moved(x, y)
    self.cam_zoom = self.cam_zoom + (0.2 * y)
    MainCamera:set_scale(vec2(self.cam_zoom, self.cam_zoom))
end

function Game:key_pressed(key)
    if key == "space" then
        if self:ball_on_ground() then
            self.ball_speed[2] = -self.jump_velocity
            self.ball_spin_rate = self.jump_spin_rate
        end
    end
end

function Game:key_released(key)

end

function Game:ball_on_ground()
    local t = self.tile_map:tile_at(self.ball_pos + vec2(0, self.ball_radius + 2))
    return t == 1
end
