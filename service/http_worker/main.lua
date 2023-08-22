local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

local mode, protocol = ...
protocol = protocol or "http"

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

local SSLCTX_SERVER = nil
local function gen_interface(proto, fd)
	if proto == "http" then
		return {
			init = nil,
			close = nil,
			read = sockethelper.readfunc(fd),
			write = sockethelper.writefunc(fd),
		}
	else
		error(string.format("Invalid protocol: %s", proto))
	end
end

local function load_file(path)
	if path == "/" or path == "" then
		path = "/index.html"
	end
	local filename = "./client"..path
	local file = io.open (filename,"rb")
	if not file then
	    return
	end
	local data = file:read("*a")
	file:close()
	local header = {}

	if string.find(filename,".png") or string.find(filename,".gif") then
		header["Content-type"] = "Content-Type: image/png"
	end
	
	if string.find(filename,".js") then
		header["Content-type"] = "application/x-javascript"
	end
    return data,header
end

skynet.start(function()
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		local interface = gen_interface(protocol, id)
		if interface.init then
			interface.init()
		end
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(interface.read, 8192)
		if code then
			if code ~= 200 then
				response(id, interface.write, code)
			else
				local tmp = {}
				if header.host then
					table.insert(tmp, string.format("host: %s", header.host))
				end
				local path, query = urllib.parse(url)
				table.insert(tmp, string.format("path: %s", path))
				if query then
					local q = urllib.parse_query(query)
					for k, v in pairs(q) do
						table.insert(tmp, string.format("query: %s= %s", k,v))
					end
				end
				
				local data,ret_header = load_file(path)
				response(id, interface.write, code, data,ret_header)
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
		if interface.close then
			interface.close()
		end
	end)
end)