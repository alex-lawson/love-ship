local function build_animation_state_quads(source_tex, frame_size, frame_padding, frame_offset, frame_count)
    local tw, th = source_tex:getDimensions()

    local quads = {}
    for i = 0, frame_count - 1 do
        local final_frame_offset = frame_offset + vec2(i, 0)
        local quad_pos = (final_frame_offset * 2 + vec2(1, 1)) * frame_padding + final_frame_offset * frame_size
        table.insert(quads, love.graphics.newQuad(quad_pos[1], quad_pos[2], frame_size[1], frame_size[2], tw, th))
    end
    return quads
end

Animation = class()

function Animation:init(conf)
    self.source_tex = load_image(conf.source_image)
    self.frame_size = vec2(conf.frame_size)
    self.frame_padding = vec2(conf.frame_padding)
    self.default_state = conf.default_state

    self.position = vec2(conf.position)
    self.centered = conf.centered or false
    if self.centered then
        self.draw_offset = self.frame_size * -0.5
    else
        self.draw_offset = vec2()
    end

    self.rate = 1.0

    self.states = {}
    for state_name, state_conf in pairs(conf.states) do
        self.states[state_name] = {
            frames = state_conf.frames,
            cycle = state_conf.cycle,
            transition = state_conf.transition,
            quads = build_animation_state_quads(self.source_tex, self.frame_size, self.frame_padding, vec2(state_conf.frame_offset), state_conf.frames)
        }
    end

    self:set_state(self.default_state)
end

function Animation:update(dt)
    self.state_cycle = self.state_cycle + self.rate * dt

    if self.state_cycle >= self.state.cycle then
        if self.state.transition == "End" then
            self.state_cycle = self.state.cycle
        elseif self.state.transition == "Loop" then
            self.state_cycle = self.state_cycle % self.state.cycle
        elseif self.state.transition:starts_with("Into:") then
            self:set_state(self.state.transition:sub(6))
        else
            errorf("Invalid Animation transition type '%s'", self.state.transition)
        end
    end
end

function Animation:draw()
    local frame_index = clamp(math.floor((self.state_cycle / self.state.cycle) * self.state.frames) + 1, 1, self.state.frames)
    love.graphics.draw(self.source_tex, self.state.quads[frame_index], self.position[1] + self.draw_offset[1], self.position[2] + self.draw_offset[2])
end

function Animation:set_state(state_name, reset_cycle)
    if reset_cycle or state_name ~= self.state_name then
        if self.states[state_name] then
            self.state = self.states[state_name]
            self.state_name = state_name
            self.state_cycle = 0

            return true
        else
            errorf("No such state '%s' in Animation", state_name)
        end
    end

    return false
end

function Animation:set_position(pos)
    self.position = pos
end

function Animation:set_centered(centered)
    self.centered = centered
    if self.centered then
        self.draw_offset = self.frame_size * -0.5
    else
        self.draw_offset = vec2()
    end
end

function Animation:set_rate(rate)
    assert(rate >= 0, "Animation rate must not be negative!")
    self.rate = rate
end
