DebugLog = class()

function DebugLog:init(config)
    config = config or {}

    self.render_position = config.render_position or vec2(5, 5)
    self.render_spacing = config.render_spacing or vec2(0, 15)
    self.render_font = config.render_font or love.graphics.newFont(12)
    self.render_color = config.render_color or {255, 255, 255, 255}

    self.message_time = config.message_time or 2.0
    self.message_fade_time = config.message_fade_time or 0.5

    self.messages = {}
end

function DebugLog:update(dt)
    local new_messages = {}

    for _, m_pair in ipairs(self.messages) do
        m_pair[2] = m_pair[2] - dt
        if m_pair[2] > 0 then
            table.insert(new_messages, m_pair)
        end
    end

    self.messages = new_messages
end

function DebugLog:render()
    local pos = self.render_position

    love.graphics.setFont(self.render_font)
    for _, m_pair in ipairs(self.messages) do
        local alpha = math.min(1.0, m_pair[2] / self.message_fade_time)
        love.graphics.setColor(
                self.render_color[1],
                self.render_color[2],
                self.render_color[3],
                math.floor(alpha * self.render_color[4]))

        love.graphics.print(m_pair[1], unpack(pos))
        pos = pos + self.render_spacing
    end
end

function DebugLog:message(message_fstring, ...)
    table.insert(self.messages, 1, {string.format(message_fstring, ...), self.message_time})
end
