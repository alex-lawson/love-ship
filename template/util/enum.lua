function enum(t)
    local enum = {}
    local key_map = map_object(t, function(k, v) return v, k end)

    function enum.to_string(v)
        return key_map[v]
    end

    function enum.from_string(k)
        return enum[k]
    end

    setmetatable(enum, {
        __index = function(e, k)
            local v = rawget(t,k)
            if v == nil then
                error(string.format("Invalid enum value %s", k))
            end
            return v
        end,
        __newindex = function()
            error("Cannot assign value to constant enum type")
        end
    })

    return enum
end
