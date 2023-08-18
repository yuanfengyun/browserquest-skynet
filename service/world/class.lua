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

return M