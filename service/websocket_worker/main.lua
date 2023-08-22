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
	skynet.send(".world","lua","connect",skynet.self(),id)
end

function handle.message(id, msg, msg_type)
	assert(msg_type == "binary" or msg_type == "text")
	skynet.error(msg_type.." "..msg)
	local package = json.decode(msg)
	print("recv:",msg)
    skynet.send(".world","lua","message",skynet.self(),id,package)
end

function handle.ping(id)
	print("ws ping from: " .. tostring(id) .. "\n")
end

function handle.pong(id)
	print("ws pong from: " .. tostring(id))
end

function handle.close(id, code, reason)
	print("ws close from: " .. tostring(id), code, reason)
	skynet.send(".world","lua","onclose",skynet.self(),id)
end

function handle.error(id)
	print("ws error from: " .. tostring(id))
end

local CMD = {}

function CMD.connect(id,addr)
	local ok, err = websocket.accept(id, handle, "ws", addr)
	if not ok then
		print(err)
	end
end

function CMD.send(id,msg)
	if type(msg) == "table" then
        msg = json.encode(msg)
    end
	print("send to client:",msg)
	websocket.write(id, msg)
end

skynet.start(function ()
	skynet.dispatch("lua", function (_,_, cmd,...)
		print("cmd",cmd)
		local f = CMD[cmd]
		f(...)
	end)
end)
