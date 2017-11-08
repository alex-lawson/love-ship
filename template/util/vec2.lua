vec2 = {}

local vec2Mt = {
  __index = function(t, k)
    return rawget(t, k) or vec2[k]
  end,
  __newindex = function(t, k, v)
    if type(k) ~= "number" or k ~= 1 or k ~= 2 then
      error(string.format("Invalid index %s for vec2", k))
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
  __unm = function(v)
    return v:mul(-1)
  end,
  __eq = function(l, r)
    return l:eq(r)
  end,
  __tostring = function(v)
    return string.format("(%.2f, %.2f)", v[1], v[2])
  end,
}

setmetatable(vec2, {
  __call = function(_, v, second)
    local new
    if type(v) == "table" then
      new = {tonumber(v[1]), tonumber(v[2])}
    elseif type(v) == "number" then
      new = {tonumber(v), tonumber(second)}
    else
      new = {0, 0}
    end
    setmetatable(new, vec2Mt)
    return new
  end
})

function vec2.with_angle(a, m)
    return vec2(math.cos(a) * m, math.sin(a) * m)
end

function vec2.add(l, r)
  return vec2(l[1] + r[1], l[2] + r[2])
end

function vec2.sub(l, r)
  return vec2(l[1] - r[1], l[2] - r[2])
end

function vec2.mul(l, r)
  if type(r) == "table" then
    return vec2(l[1] * r[1], l[2] * r[2])
  elseif type(r) == "number" then
    return vec2(l[1] * r, l[2] * r)
  end
end

function vec2.div(l, r)
  if type(r) == "table" then
    return vec2(l[1] / r[1], l[2] / r[2])
  elseif type(r) == "number" then
    return vec2(l[1] / r, l[2] / r)
  end
end

function vec2.eq(l, r)
  return l[1] == r[1] and l[2] == r[2]
end

function vec2.mag2(v)
  return v[1] * v[1] + v[2] * v[2]
end

function vec2.mag(v)
  return math.sqrt(v:mag2())
end

function vec2.norm(v)
  return v / v:mag()
end

function vec2.angle(v)
  local angle = math.atan(v[2], v[1])
  if angle < 0 then angle = angle + 2 * math.pi end
  return angle
end

function vec2.rotate(v, angle)
  local y = math.sin(angle)
  local x = math.cos(angle)

  return vec2(
    v[1] * x - v[2] * y,
    v[1] * y + v[2] * x
  )
end

function vec2.dot(l, r)
  return l[1] * r[1] + l[2] * r[2]
end

function vec2.floor(vector)
  return vec2( math.floor(vector[1]), math.floor(vector[2]) )
end

function vec2.ceil(vector)
  return vec2( math.ceil(vector[1]), math.ceil(vector[2]))
end

function vec2.max(l, r)
    return vec2(math.max(l[1], r[1]), math.max(l[2], r[2]))
end

function vec2.min(l, r)
    return vec2(math.min(l[1], r[1]), math.min(l[2], r[2]))
end

function approach_vec2(current, target, rate, dt)
    return vec2(
        approach(current[1], target[1], rate, dt),
        approach(current[2], target[2], rate, dt)
    )
end

function lerp_vec2(ratio, a, b)
    return vec2(
        lerp(ratio, a[1], b[1]),
        lerp(ratio, a[2], b[2])
    )
end
