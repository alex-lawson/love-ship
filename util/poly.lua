poly = {}

local polyMt = {
    __index = function(t, k)
        return rawget(t, k) or poly[k]
    end,
    __newindex = function(t, k, v)
        rawset(t, k, tonumber(v))
    end,
    __eq = function(l, r)
        return l:eq(r)
    end,
    __tostring = function(p)
        local s = "{"
        for i,v in ipairs(p) do
            s = s..tostring(v)
            if i ~= #p then
                s = s..", "
            end
        end
        s = s.."}"
        return s
    end,
}

setmetatable(poly, {
    __call = function(_, v, second, third, fourth)
        local p
        if type(v) == "table" then
            p = map(v, vec2)
        elseif p == nil then
            p = {}
        end
        setmetatable(p, polyMt)
        return p
    end
})

function poly.bounds(p)
    if p[1] == nil then
        error("Cannot get bounds of empty poly")
    else
        local bounds = rect.with_size(p[1], vec2())
        for _, v in ipairs(p) do
            bounds = bounds:combine(rect.with_size(v, vec2()))
        end
        return bounds
    end
end

function poly.size(p)
    return p:bounds():size()
end

function poly.translate(p, d)
    return poly(map(p, function(v) return v + d end))
end

function poly.scale(p, scale)
    return poly(map(p, function(v) return v * scale end))
end

function poly.intersects(l, r)
    return rmath.poly_intersects(l, r)
end

function poly.lines(p)
    local lines = {}
    if #p < 3 then
        error("Cannot get lines of poly with less than 3 vertices")
    end
    for i = 1, #p do
        local n = i + 1
        if n > #p then
            n = 1
        end
        table.insert(lines, {
            vec2(p[i]),
            vec2(p[n])
        })
    end
    return lines
end
