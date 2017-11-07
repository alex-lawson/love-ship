Camera = class()

function Camera:init()
    self.view_scale = vec2(1, 1)
    self.screen_center = vec2(love.graphics.getDimensions()) * 0.5
    self.view_center = vec2(self.screen_center)
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
