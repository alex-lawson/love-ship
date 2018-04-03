function class(...)
    local class, bases = {}, {...}
    -- copy base class contents into the new class
    for i, base in ipairs(bases) do
        for k, v in pairs(base) do
            class[k] = v
        end
    end
    -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
    -- so you can do an "instance of" check using my_instance.is_a[MyClass]
    class.__index, class.is_a = class, {[class] = true}
    for i, base in ipairs(bases) do
        for c in pairs(base.is_a) do
            class.is_a[c] = true
        end
        class.is_a[base] = true
    end
    -- the class's __call metamethod
    setmetatable(class, {__call = function (c, ...)
                           local instance = setmetatable({}, c)
                           -- run the init method if it's there
                           local init = instance.init
                           if init then init(instance, ...) end
                           return instance
    end})
    -- return the new class table, that's ready to fill with methods
    return class
end

function errorf(fstring, ...)
    error(string.format(fstring, ...))
end

function printf(fstring, ...)
    print(string.format(fstring, ...))
end

function copy(v)
    if type(v) ~= "table" then
        return v
    else
        local c = {}
        for k,v2 in pairs(v) do
            c[k] = copy(v2)
        end
        local mt = getmetatable(v)
        if mt then
            setmetatable(c, mt)
        end
        return c
    end
end

function printr(v, indent)
    local out = ""
    local indent = indent or ""
    local newIndent = indent .. "  "
    if type(v) == "table" then
        out = out .. "{"
        for k,v in pairs(v) do
            out = out .. string.format("\n%s%s = %s", newIndent, printr(k, newIndent), printr(v, newIndent))
        end
        out = out .. string.format("\n%s}", indent)
    elseif type(v) == "string" then
        out = string.format("\"%s\"", v)
    else
        out = tostring(v)
    end

    return out
end

-- If a is null, returns b, if b is null, returns a, if a and b are not null,
-- returns op(a, b)
function opt_combine(a, b, op)
    if a == nil then
        return b
    elseif b == nil then
        return a
    else
        return op(a, b)
    end
end

function opt_def(o, def)
    return opt_combine(o, def, function(v, _) return v end)
end

function opt_min(a, b)
    return opt_combine(a, b, math.min)
end

function opt_max(a, b)
    return opt_combine(a, b, math.min)
end

function keys(t)
    local ks = {}
    for k,_ in pairs(t) do
        table.insert(ks, k)
    end
    return ks
end

function map(list, func)
    local new_list = {}
    for i,v in ipairs(list) do
        new_list[i] = func(v)
    end
    return new_list
end

function filter(list, func)
    local new_list = {}
    for i,v in ipairs(list) do
        if func(v) then
            table.insert(new_list, v)
        end
    end
    return new_list
end

function map_object(object, func)
    local new_object = {}
    for k,v in pairs(object) do
        local new_k, new_v = func(k, v)
        new_object[new_k] = new_v
    end
    return new_object
end

function fold(list, acc, f)
    for _,v in ipairs(list) do
        acc = f(acc, v)
    end
    return acc
end

function group_by(list, f)
    local groups = {}
    for _,v in ipairs(list) do
        local group_key = f(v)
        local g = groups[group_key] or {}
        table.insert(g, v)
        groups[group_key] = g
    end
    return groups
end

function find(list, cmp)
    for k,v in ipairs(list) do
        if cmp(v) then
            return k
        end
    end
    return nil
end

function any(list, cmp)
    for k,v in ipairs(list) do
        if cmp(v) then
            return true
        end
    end
    return false
end

function merge(lhs, rhs)
    lhs = copy(lhs)
    for k,v in pairs(rhs) do
        if type(v) == "table" and lhs[k] ~= nil and type(lhs[k]) == "table" then
            lhs[k] = merge(lhs[k], v)
        else
            lhs[k] = copy(v)
        end
    end
    return lhs
end

function rev_ipairs(t)
    local i = #t
    return function()
        local j, e = i, t[i]
        if e then
            i = i - 1
            return j, e
        end
    end
end

function append(lhs, ...)
    lhs = copy(lhs)
    for _, rhs in ipairs({...}) do
        for _, v in ipairs(rhs) do
            table.insert(lhs, v)
        end
    end
    return lhs
end

function values(t)
    local vals = {}
    for _, v in pairs(t) do
        table.insert(vals, v)
    end
    return vals
end

function contains(list, item)
    for _, v in ipairs(list) do
        if compare(item, v) then
            return true
        end
    end
    return false
end

function shuffle(t)
    for i, _ in ipairs(t) do
        local j = love.math.random(1, #t)
        t[i], t[j] = t[j], t[i]
    end
end

function string:starts_with(s)
    return self:sub(1, s:len()) == s
end

function string:ends_with(s)
    return s == '' or self:sub(-s:len()) == s
end

function compare(t1, t2)
    if t1 == t2 then return true end
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return false end

    if getmetatable(t1).__eq ~= nil or getmetatable(t2).__eq ~= nil then
        -- tables with metamethods for '==' comparisons should not compare recursively
        return false
    end

    for k,v in pairs(t1) do
        if not compare(v, t2[k]) then return false end
    end
    for k,v in pairs(t2) do
        if not compare(v, t1[k]) then return false end
    end
    return true
end

function match(v)
    return function(options)
        local f = options[v]
        if f then
            return f()
        else
            error(string.format("Value %s not handled in match", printr(v)))
        end
    end
end

function make_set(t)
    local s = {}
    for _, i in pairs(t) do
        s[i] = true
    end
    return s
end

function set_intersection(s1, s2)
    local s = {}
    for k, _ in pairs(s1) do
        if s2[k] then
            s[k] = true
        end
    end
    return s
end

-- Optionally gets a value in a deep table structure
function opt_get_path(t, ...)
    for _, k in ipairs({...}) do
        if t[k] then
            t = t[k]
        else
            return nil
        end
    end
    return t
end

-- Constructs a path by creating an empty table at the end if it doesn't already exist
-- returns the result, which should always be a table
function construct_path(t, ...)
    for _, k in ipairs({...}) do
        t[k] = t[k] or {}
        t = t[k]
    end
    return t
end
