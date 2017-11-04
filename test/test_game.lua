require "test/animation_configs"

Game = class()

function Game:init()
    MainCamera:set_center(vec2())
    self.cam_zoom = 1.0

    self.ball = Animation(animation_configs.ball)
end

function Game:update(dt)
    self.ball:update(dt)
end

function Game:render()
    self.ball:draw(vec2())
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
