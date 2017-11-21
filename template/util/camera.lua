Camera = class()

function Camera:init()
    self.view_scale = vec2(1, 1)
    self.screen_size = vec2(love.graphics.getDimensions())
    self.screen_center = self.screen_size * 0.5
    self.view_center = vec2()
end

function Camera:resize(new_size)
    self.screen_size = new_size
    self.screen_center = new_size * 0.5
end

function Camera:set_scale(new_scale)
    if type(new_scale) == "table" then
        self.view_scale = new_scale
    else
        self.view_scale = vec2(new_scale, new_scale)
    end
end

function Camera:scale(scale_factor)
    self.view_scale = self.view_scale * scale_factor
end

function Camera:set_center(new_center)
    self.view_center = new_center
end

function Camera:translate(translate_by)
    self.view_center = self.view_center + translate_by
end

function Camera:world_to_screen(pos)
    return (pos - self.view_center) * self.view_scale + self.screen_center
end

function Camera:screen_to_world(pos)
    return (pos - self.screen_center) / self.view_scale + self.view_center
end

function Camera:do_transform()
    love.graphics.scale(unpack(self.view_scale))
    love.graphics.translate(unpack(self.screen_center / self.view_scale - self.view_center))
end

function Camera:show_rect(world_rect)
    self:set_center(world_rect:center())

    local w_r_size = world_rect:size()
    local x_scale = self.screen_size[1] / w_r_size[1]
    local y_scale = self.screen_size[2] / w_r_size[2]

    self:set_scale(math.min(x_scale, y_scale))
end
