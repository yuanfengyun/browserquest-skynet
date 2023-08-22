
local Utils = require('utils')
local Types = require("share")
local Class = require "class"

local M = Class.Class()

function M.new(...)
    local o = {}
    setmetatable(o,M)
    o:init(...)
    return o
end

function M:init(id, x, y, width, height)
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
end
    
function M:getRandomPosition()
        local pos = {}
        
        pos.x = self.x + Utils.randomInt(0, self.width - 1)
        pos.y = self.y + Utils.randomInt(0, self.height - 1)
        return pos
end

return M