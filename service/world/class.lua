local M = {}

function M.Class(base)
    local c
    c = {
        _base = base,
        __index = function(t,k)
            local v = c[k]
            if v then
                return v
            end

            local b = c._base
            while b do
                local vv = b[k]
                if vv then
                    return vv
                end
                b = b._base
            end
        end
    }
    return c
end

function instanceof(a,b)
    local meta = getmetatable(a)
    local base = meta
    while base do
        if base == b then
            return true
        end

        if base._base then
            base = base._base
        else
            break
        end
    end

    return false
end

return M