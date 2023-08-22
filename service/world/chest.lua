
local Utils = require("utils")
local Types = require("share")
local class = require "class"
local Item = require "item"

local M = class.Class(Item)

function M.new(...)
    local o = setmetatable({},M)
    o:init(...)
    return o
end

function M:init(id, x, y)
    M._base.init(self,id, Types.Entities.CHEST, x, y)
end
    
function M:setItems(items)
    self.items = items
end
    
function M:getRandomItem()
    local nbItems = #self.items
    local item = nil

    if nbItems > 0 then
        item = self.items[Utils.random(nbItems)]
    end
    return item
end

return M