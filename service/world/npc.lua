local class = require "class"
local item = require "item"

local M = class.Class(item)

function M.new(...)
    local o = setmetatable({},M)
    o:init(...)
    return o
end

function M:init(id,kind,x,y)
    M._base.init(self,id,"npc",kind,x,y)
end

return M