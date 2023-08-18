
luaservice = "./service/?.lua;./service/?/main.lua;./skynet/service/?.lua;"
cpath = "./cservice/?.so;./skynet/cservice/?.so;"
lua_path = "./lualib/?.lua;./lualib/?/init.lua;./skynet/lualib/?.lua;./skynet/lualib/?/init.lua;"
lua_cpath = "./luaclib/?.so;./skynet/luaclib/?.so;"

lualoader = "skynet/lualib/loader.lua"

-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 4
logger = nil
logpath = "."
harbor = 0
start = "main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap
-- daemon = "./skynet.pid"