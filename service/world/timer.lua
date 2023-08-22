local skynet = require "skynet"

local M = {
    id = 0,
    map = {}
}

function M.setTimeout(f,t)
    M.id = M.id + 1
    local id = M.id

    skynet.timeout(math.floor(t),function() M.callback(id) end)

    M.map[id] = f

    return id
end

function M.callback(id)
    local f = M.map[id]
    if not f then
        return
    end

    f()
end

function M.clearTimeout(id)
    M.map[id] = nil
end

setInterval = function(f,t)
    local ff
    ff = function()
        skynet.timeout(t,ff)
        f()
    end
    skynet.timeout(t,ff)
end

setTimeout = M.setTimeout
clearTimeout = M.clearTimeout

return M