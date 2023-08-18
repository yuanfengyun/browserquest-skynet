local class = require "class"
local item = require "item"

local M = class.Class(item)

function M.new()
    return setmetatable({},M)
end

function M:init(id,kind,x,y)
    self._super.init(self,id,"npc",kind,x,y)
end

return M