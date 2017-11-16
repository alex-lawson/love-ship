FpsCounter = class()

function FpsCounter:init(config)
    config = config or {}

    self.sample_period = config.sample_period or 0.5
    self.render_position = config.render_position or vec2(5, 5)
    self.render_font = config.render_font or love.graphics.newFont(12)
    self.render_color = config.render_color or {255, 255, 255, 255}

    self.sample_time = self.sample_period
    self.frames = 0

    self.fps = 0

    self.enabled = true
end

function FpsCounter:update(dt)
    self.sample_time = self.sample_time - dt
    if self.sample_time <= 0 then
        self.fps = self.frames / (self.sample_period - self.sample_time)

        self.frames = 0
        self.sample_time = self.sample_period
    end
end

function FpsCounter:render()
    self.frames = self.frames + 1

    if self.enabled then
        love.graphics.setFont(self.render_font)
        love.graphics.setColor(unpack(self.render_color))
        love.graphics.print(string.format("%.1f FPS", self.fps), unpack(self.render_position))
    end
end
