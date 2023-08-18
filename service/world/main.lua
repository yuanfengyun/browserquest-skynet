local skynet = require "skynet"
require "skynet.manager"
require "timer"
local json = require "dkjson"

local CMD = {}

function CMD.message(gate,id,message)
    local message_id = message[1]
    print(message_id)

    local t = {1,111, "aaaaa", 50, 50, 100}
    skynet.send(gate,"lua","send",id,json.encode(t))
end

skynet.start(function()
    skynet.dispatch("lua",function(session,source,cmd,...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
    skynet.register("world")
end)