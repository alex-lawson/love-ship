-- converts RGB values in the range of 0-1
-- to HSV values in the range of 0-360, 0-1, and 0-1 respectively
function rgb_to_hsv(r, g, b)
    r, g, b = r, g, b

    local min = math.min(r, g, b)
    local max = math.max(r, g, b)

    if min == max then
        return 0, 0, max
    end

    local d = max - min

    local h
    if r == max then
        h = (g - b) / d
    elseif g == max then
        h = 2 + (b - r) / d
    else
        h = 4 + (r - g) / d
    end

    h = (h * 60) % 360

    local s = (d / max)
    local v = max

    return h, s, v
end

-- converts HSV values in the range of 0-360, 0-1, and 0-1 respectively
-- to RGB values in the range of 0-1
function hsv_to_rgb(h, s, v)
    h, s, v = h / 360, s, v

    local i = math.floor(h * 6) % 6
    local f = (h * 6) - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local r, g, b
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

-- converts R, G, B values in the range of 0-1 to an *integer* hex representation (rounding may occur)
function rgb_to_hex(r, g, b)
    r = math.floor(r * 255 + 0.5)
    g = math.floor(g * 255 + 0.5)
    b = math.floor(b * 255 + 0.5)

    local hex_string = string.format("%02x%02x%02x", r, g, b)

    return hex_string
end

-- converts a hex string e.g. "AC2DF3" to R, G, B values in the range of 0-1
function hex_to_rgb(hex_string)
    local r = tonumber(hex_string:sub(1, 2), 16) / 255
    local g = tonumber(hex_string:sub(3, 4), 16) / 255
    local b = tonumber(hex_string:sub(5, 6), 16) / 255

    return r, g, b
end
