local class = require "class"
local Entity = require "entity"
local Messages = require "message"


local Utils = require("utils")
local Properties = require("propertites")
local Types = require("share")


local M = class.Class(Entity)

function M:init(id, type, kind, x, y)
    M._base.init(self,id, type, kind, x, y)
    
    self.orientation = Utils.randomOrientation()
    self.attackers = {}
    self.target = nil
end
    
function M:getState()
        local basestate = self:_getBaseState()
        local state = {self.orientation}
        
        if(self.target) then
            table.insert(state,self.target)
        end
        
        return basestate.concat(state)
    end
    
    function M:resetHitPoints(maxHitPoints)
        self.maxHitPoints = maxHitPoints
        self.hitPoints = self.maxHitPoints
    end
    
    function M:regenHealthBy(value)
        local hp = self.hitPoints
        local max = self.maxHitPoints
            
        if(hp < max) then
            if(hp + value <= max) then
                self.hitPoints = value + self.hitPoints
            else
                self.hitPoints = max;
            end
        end
    end
    
    function M:hasFullHealth()
        return self.hitPoints == self.maxHitPoints
    end
    
    function M:setTarget(entity)
        self.target = entity.id
    end
    
    function M:clearTarget()
        self.target = nil
    end
    
    function M:hasTarget()
        return self.target ~= nil
    end
    
    function M:attack()
        return Messages.Attack.new(self.id, self.target)
    end
    
    function M:health()
        return Messages.Health.new(self.hitPoints, false)
    end
    
    function M:regen()
        return Messages.Health.new(self.hitPoints, true);
    end
    
    function M:addAttacker(entity)
        if(entity) then
            self.attackers[entity.id] = entity
        end
    end
    
    function M:removeAttacker(entity) 
        if entity and inin( entity.id , self.attackers) then
            self.attackers[entity.id] = nil
            --log.debug(self.id +" REMOVED ATTACKER "+ entity.id);
        end
    end
    
    function M:forEachAttacker(callback)
        for id,_ in pairs(self.attackers) do
            callback(self.attackers[id])
        end
    end

    return M