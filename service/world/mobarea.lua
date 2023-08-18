
local class = require "class"
local Area = require "area"
local Types = require "types"
local Mob = require "mob"

local M = class.Class(Area)

function M:init(id, nb, kind, x, y, width, height, world)
    self._super(id, x, y, width, height, world)
    self.nb = nb
    self.kind = kind
    self.respawns = {}
    self:setNumberOfEntities(self.nb)
    
    --self.initRoaming()
end

function M:getType()
    return "mobarea"
end

function M:spawnMobs()
    for i = 0,self.nb-1 do
        self:addToArea(self:_createMobInsideArea())
    end
end

function M:_createMobInsideArea()
    local k = Types.getKindFromString(self.kind)
    local pos = self:_getRandomPositionInsideArea()
    local mob = Mob.new('1' + self.id + ''+ k + ''+ self.entities.length, k, pos.x, pos.y)
    
    mob:onMove(self.world.onMobMoveCallback.bind(self.world))

    return mob
end

function M:respawnMob(mob, delay)
    self:removeFromArea(mob)
    
    setTimeout(function()
        local pos = self:_getRandomPositionInsideArea()
        
        mob.x = pos.x
        mob.y = pos.y
        mob.isDead = false
        self.addToArea(mob)
        self.world.addMob(mob)
    end, delay)
end

function M:initRoaming(mob)
    setInterval(function()
        for _,mod in pairs(self.entities) do
            local canRoam = math.random(20) == 1
            if canRoam then
                if ~mob.hasTarget() and ~mob.isDead then
                    local pos = self:_getRandomPositionInsideArea()
                    mob:move(pos.x, pos.y)
                end
            end
        end
    end, 500)
end

function M:createReward()
    local pos = self:_getRandomPositionInsideArea()
    
    return {x= pos.x, y= pos.y, kind=Types.Entities.CHEST}
end

return M