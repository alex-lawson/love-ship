rect = {}

local rectMt = {
    __index = function(t, k)
        return rawget(t, k) or rect[k]
    end,
    __newindex = function(t, k, v)
        if type(k) ~= "number" or k ~= 1 or k ~= 2 then
            error(string.format("Invalid index %s for rect", k))
        end
        rawset(t, k, tonumber(v))
    end,
    __add = function(l, r)
        return l:add(r)
    end,
    __sub = function(l, r)
        return l:sub(r)
    end,
    __mul = function(l, r)
        return l:mul(r)
    end,
    __div = function(l, r)
        return l:div(r)
    end,
    __eq = function(l, r)
        return l:eq(r)
    end,
    __tostring = function(v)
        return string.format("(%s, %s, %s, %s)", v[1], v[2], v[3], v[4])
    end,
}

setmetatable(rect, {
    __call = function(_, v, second, third, fourth)
        local r
        if type(v) == "table" then
            if #v == 2 then
                r = {v[1], v[2], second[1], second[2]}
            else
                r = {v[1], v[2], v[3], v[4]}
            end
        elseif type(v) == "number" then
            r = {v, second, third, fourth}
        elseif v == nil then
            r = {0, 0, 0, 0}
        end
        setmetatable(r, rectMt)
        return r
    end
})

function rect.add(r, v)
    return rect(r:min() + v, r:max() + v)
end

function rect.sub(r, v)
    return rect(r:min() - v, r:max() - v)
end

function rect.mul(r, v)
    return rect(r:min() * v, r:max() * v)
end

function rect.div(r, v)
    return rect(r:min() / v, r:max() / v)
end

function rect.min(r)
    return vec2(r[1], r[2])
end

function rect.max(r)
    return vec2(r[3], r[4])
end

rect.ll = rect.min

function rect.ul(r)
    return vec2(r:min()[1], r:max()[2])
end

rect.ur = rect.max

function rect.lr(r)
    return vec2(r:max()[1], r:min()[2])
end

-- rect from two vec2, not order dependant
function rect.from_points(first, second)
    return rect(
        math.min(first[1], second[1]),
        math.min(first[2], second[2]),
        math.max(first[1], second[1]),
        math.max(first[2], second[2])
    )
end

function rect.with_size(min, size)
    return rect(min[1], min[2], min[1] + size[1], min[2] + size[2])
end

function rect.with_center(center, size)
    return rect.with_size(center, size):translate(size * -0.5)
end

function rect.size(r)
    return vec2(r[3] - r[1], r[4] - r[2])
end

function rect.center(r)
    return r:min() + (r:size() / 2.0)
end

function rect.translate(r, v)
    return rect(r:min() + v, r:max() + v)
end

function rect.scale(r, scale)
    return rect(r:min() * scale, r:max() * scale)
end

function rect.pad(r, pad)
    return rect(r:min() - pad, r:max() + pad)
end

function rect.overlaps(l, r)
    return not (l[1] > r[3] or l[3] < r[1] or l[2] > r[4] or l[4] < r[2])
end

function rect.contains(r, v)
    return v[1] >= r[1]
        and v[2] >= r[2]
        and v[1] <= r[3]
        and v[2] <= r[4]
end

function rect.combine(l, r)
    if #r > 2 then
        return rect(
            math.min(l[1], r[1]),
            math.min(l[2], r[2]),
            math.max(l[3], r[3]),
            math.max(l[4], r[4])
        )
    else
        return rect(
            math.min(l[1], r[1]),
            math.min(l[2], r[2]),
            math.max(l[3], r[1]),
            math.max(l[4], r[2])
        )
    end
end

function rect.poly(r)
    return poly({
        vec2(r[1], r[2]),
        vec2(r[3], r[2]),
        vec2(r[3], r[4]),
        vec2(r[1], r[4])
    })
end

function rect.lines(r)
    return {
        {r:ll(), r:lr()},
        {r:ll(), r:ul()},
        {r:ul(), r:ur()},
        {r:lr(), r:ur()}
    }
end
