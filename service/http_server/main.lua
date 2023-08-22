local skynet = require "skynet"
local socket = require "skynet.socket"
local string = string

local SERVICE_NAME = "http_worker"

skynet.start(function()
	local agent = {}
	local protocol = "http"
	for i= 1, 5 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent", protocol)
	end
	local balance = 1
	local lid = socket.listen("0.0.0.0", 8001)
	skynet.error(string.format("Listen web port 8001 protocol:%s", protocol))
	socket.start(lid , function(id, addr)
		--skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
		skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)