local skynet = require "skynet"

skynet.start(function()
    skynet.error("start begin...")
	
	skynet.newservice("http_server")
	
	skynet.newservice("websocket_server")

	skynet.newservice("world")
end)