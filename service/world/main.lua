local skynet = require "skynet"
require "skynet.manager"
require "timer"
require "util"
local json = require "dkjson"
local World = require "worldserver"
local Player = require "player"

local CMD = {}

player_map = {}
player_2_fd = {}
fd_2_player = {}
fd_2_gate = {}

function send_to_client(fd,message)
    local gate = fd_2_gate[fd]
    skynet.send(gate,"lua","send",fd,message)
end

function send_to_player(id,message)
    local fd = player_2_fd[id]
    local gate = fd_2_gate[fd]

    skynet.send(gate,"lua","send",fd,message)
end

worlds = {}
function CMD.start()
    for i=1,1 do
        worlds[i] = World.new(i,100)
        worlds[i]:run("./maps/world_server.json")
    end
end

function CMD.connect(gate,fd)
    fd_2_gate[fd] = gate

    local p = Player.new(fd)
    p:init(fd,worlds[1])
    worlds[1].connect_callback(p)
    fd_2_player[fd] = p
end

function CMD.message(gate,id,message)
    local p = fd_2_player[id]
    p:dispatchMessage(message)
end

function CMD.onclose(gate,fd)
    local p = fd_2_player[fd]
    p:onClose()
end

skynet.start(function()
    skynet.dispatch("lua",function(session,source,cmd,...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
    skynet.register(".world")
end)