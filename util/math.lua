function sign(v)
    if v >= 0 then
        return 1
    else
        return -1
    end
end

function lerp(ratio, a, b)
    if type(a) == "table" then
        return a[1] + (a[2] - a[1]) * ratio
    else
        return a + (b - a) * ratio
    end
end

function lerp_vec2(ratio, a, b)
    return vec2(
        lerp(ratio, a[1], b[1]),
        lerp(ratio, a[2], b[2])
    )
end

function angle_diff(from, to)
  return ((((to - from) % (2*math.pi)) + (3*math.pi)) % (2*math.pi)) - math.pi
end

function round(x, decimals)
    decimals = decimals or 0
    return math.floor((x * (10 ^ decimals)) + 0.5) / (10 ^ decimals)
end

-- Returns whether the three given points are in a straight line (returns 0),
-- go counter clockwise (returns > 0) or go clockwise (returns < 0)
function winding_direction(p1, p2, p3)
    return (p1[1] - p3[1]) * (p2[2] - p3[2]) - (p2[1] - p3[1]) * (p1[2] - p3[2])
end
