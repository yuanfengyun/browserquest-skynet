local skynet = require "skynet"

local CMD = {}

skynet.start(function()
    skynet.dispatch("lua",function(_,_,cmd,...)
        local f = CMD[cmd]
        if not f then
            return
        end

        skynet.ret(skynet.pack(f(...)))
    end)
end)