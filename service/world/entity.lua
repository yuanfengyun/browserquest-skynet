local Messages = require "Message"

local M = {}

function M:init(id,type,kind,x,y)
    self.id = id
    self.type = type
    self.kind = kind
    self.x = x
    self.y = y
end

function M:_getBaseState()
    return {
        tonumber(self.id),
        self.kind,
        self.x,
        self.y
    }
end

function M:getType()
    return "unknow"
end

function M:getState()
    return self:_getBaseState()
end

function M:spawn()
    return Messages.Spawn.new(self)
end

function M:despawn()
    return Messages.Despawn.new(self.id)
end

function M:setPosition(x, y)
    self.x = x
    self.y = y
end

function M:getPositionNextTo(entity)
    local pos = nil
    if entity then
        pos = {}
        -- This is a quick & dirty way to give mobs a random position
        -- close to another entity.
        local r = math.random(0,3)
        
        pos.x = entity.x
        pos.y = entity.y
        if r == 0 then
            pos.y = pos.y - 1
        elseif r == 1 then
            pos.y = pos.y + 1
        elseif r == 2 then
            pos.x = pos.x - 1
        elseif r == 3 then
            pos.x = pos.x + 1
        end
    end
    return pos
end

return M