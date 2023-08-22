local M = {}

function M:init(id, x, y, width, height, world)
    self.id = id
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.world = world
    self.entities = {}
    self.hasCompletelyRespawned = true
end

function M:getType()
    return "unknown"
end

function M:_getRandomPositionInsideArea()
    local pos = {}
    local valid = false
    
    while not valid do
        pos.x = self.x + math.random(self.width + 1)
        pos.y = self.y + math.random(self.height + 1)
        valid = self.world:isValidPosition(pos.x, pos.y)
    end
    return pos
end

function M:removeFromArea(entity)
    for i,v in ipairs(self.entities) do
        if v.id == entity.id then
            table.remove(self.entities,i)
            break
        end
    end
    
    if self.isEmpty() and self.hasCompletelyRespawned and self.empty_callback then
        self.hasCompletelyRespawned = false
        self:empty_callback()
    end
end

function M:addToArea(entity)
    if entity then
        table.insert(self.entities,entity)
        entity.area = self
        if entity:getType() == "mob" then
            self.world:addMob(entity)
        end
    end
    
    if self:isFull() then
        self.hasCompletelyRespawned = true
    end
end

function M:setNumberOfEntities(nb)
    self.nbEntities = nb
end

function M:isEmpty()
    for i,v in ipairs(self.entities) do
        if not v.isDead then
            return false
        end
    end


    return true
end

function M:isFull()
    return not self:isEmpty() and (self.nbEntities == #self.entities)
end

function M:onEmpty(callback)
    self.empty_callback = callback
end

return M