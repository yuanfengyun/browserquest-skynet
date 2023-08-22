local skynet = require "skynet"

skynet.start(function()
    skynet.error("start begin...")
	
	local w = skynet.newservice("world")

	skynet.call(w,"lua","start")

	skynet.newservice("http_server")
	
	skynet.newservice("websocket_server")
end)