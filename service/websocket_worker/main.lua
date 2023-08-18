local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
local websocket = require "http.websocket"
local json = require "dkjson"

local handle = {}

function handle.connect(id)
	print("ws connect from: " .. tostring(id))
end

function handle.handshake(id, header, url)
	local addr = websocket.addrinfo(id)
	print("ws handshake from: " .. tostring(id), "url", url, "addr:", addr)
	print("----header-----")
	for k,v in pairs(header) do
		print(k,v)
	end
	print("--------------")
	websocket.write(id, "go")
end

function handle.message(id, msg, msg_type)
	assert(msg_type == "binary" or msg_type == "text")
	skynet.error(msg_type.." "..msg)
	local package = json.decode(msg)
    skynet.send("world","lua","message",skynet.self(),id,package)
end

function handle.ping(id)
	print("ws ping from: " .. tostring(id) .. "\n")
end

function handle.pong(id)
	print("ws pong from: " .. tostring(id))
end

function handle.close(id, code, reason)
	print("ws close from: " .. tostring(id), code, reason)
end

function handle.error(id)
	print("ws error from: " .. tostring(id))
end

skynet.start(function ()
	skynet.dispatch("lua", function (_,_, id, cmd,...)
		if cmd == "connect" then
			local protocol, addr = table.unpack({...})
			local ok, err = websocket.accept(id, handle, protocol, addr)
			if not ok then
				print(err)
			end
	    end
	end)
end)
