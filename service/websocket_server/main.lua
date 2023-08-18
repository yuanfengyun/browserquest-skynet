local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
local websocket = require "http.websocket"

local SERVICE_NAME = "websocket_worker"

skynet.start(function ()
	local agent = {}
	for i= 1, 5 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent")
	end
	local balance = 1
	local protocol = "ws"
	local lid = socket.listen("0.0.0.0", 8000)
	skynet.error(string.format("Listen websocket port 8000 protocol:%s", protocol))
	socket.start(lid, function(id, addr)
		print(string.format("accept websocket socket_id: %s addr:%s", id, addr))
		skynet.send(agent[balance], "lua", id, protocol, addr)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)