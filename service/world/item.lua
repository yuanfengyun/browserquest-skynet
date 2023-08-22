local class = require "class"
local Entity = require "entity"

local M = class.Class(Entity)

function M.new(...)
    local o = setmetatable({},M)
    o:init(...)
    return o
end

function M:init(id, kind, x, y)
     M._base.init(self,id,"item",kind,x,y)
     self.isStatic = false
     self.isFromChest = false
end

function M:handleDespawn(params)
    self.blinkTimeout = setTimeout(function()
        params.blinkCallback()
        self.despawnTimeout = setTimeout(params.despawnCallback, params.blinkingDuration)
    end, params.beforeBlinkDelay)
end

function M:destroy()
    if self.blinkTimeout then
        clearTimeout(self.blinkTimeout)
    end
    if self.despawnTimeout then
        clearTimeout(self.despawnTimeout)
    end
    
    if self.isStatic then
        self.scheduleRespawn(30000)
    end
end

function M:scheduleRespawn(delay)
    setTimeout(function()
        if self.respawn_callback then
            self.respawn_callback()
        end
    end, delay)
end

function M:onRespawn(callback)
    self.respawn_callback = callback
end

return M