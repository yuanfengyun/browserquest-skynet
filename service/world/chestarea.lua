local class = require "class"
local Area = require "area" 

local M = class.Class(Area)

function M.new(...)
    local o = setmetatable({},M)
    o:init(...)
    return o
end

function M:init(id, x, y, width, height, cx, cy, items, world)
    M._base.init(self,id, x, y, width, height, world)
    self.items = items
    self.chestX = cx
    self.chestY = cy
end

function M:getType()
    return "chestarea"
end

function M:contains(entity)
    if entity then
        return entity.x >= self.x
            and entity.y >= self.y
            and entity.x < self.x + self.width
            and entity.y < self.y + self.height
    end
    return false
end

return M