local Types = require "types"

local M = {}

M.Spawn = {}
M.Spawn.__index = M.Spawn

M.Spawn.new = function(entity)
    return setmetatable({entity = entity},M.Spawn)
end
M.Spawn.serialize = function()
    local spawn = {Types.Messages.SPAWN}
    return table.insert(spawn,self.entity.getState())
end

M.Despawn = {}
M.Despawn.__index = M.Despawn

M.Despawn.new = function(entityId)
    return setmetatable({entityId = entityId},M.Despawn)
end

M.Despawn.serialize = function()
    return {Types.Messages.DESPAWN, self.entityId}
end

M.Move = {}
M.Move.__index = M.Move

M.Move.new = function(entity)
    return setmetatable({entity = entity},M.Move)
end

M.Move.serialize = function()
    return {Types.Messages.MOVE,self.entity.id,self.entity.x,self.entity.y}
end

M.LootMove = {}
M.LootMove.__index = M.LootMove

M.LootMove.new = function(entity, item)
    return setmetatable({entity = entity,item=item},M.LootMove)
end
M.LootMove.serialize = function()
    return {Types.Messages.LOOTMOVE,self.entity.id,self.item.id}
end

M.Attack = {}
M.Attack.__index = M.Attack
M.Attack.new = function(attackerId, targetId)
    return setmetatable({attackerId = attackerId,targetId=targetId},M.Attack)
end

M.Attack.serialize = function()
    return {Types.Messages.ATTACK,self.attackerId,self.targetId}
end

M.Health = {}
M.Health.__index = M.Health
M.Health.new = function(points, isRegen)
    return setmetatable({points = points,isRegen=isRegen},M.Health)
end

M.Health.serialize = function()
    local health = {Types.Messages.HEALTH,self.points}
    
    if self.isRegen then
        table.insert(health,1)
    end
    return health
end

M.HitPoints = {}
M.HitPoints.__index = M.HitPoints
M.HitPoints.new = function(maxHitPoints)
    return setmetatable({maxHitPoints = maxHitPoints},M.HitPoints)
end

M.HitPoints.serialize = function()
    return {Types.Messages.HP,self.maxHitPoints}
end

M.EquipItem = {}
M.EquipItem.__index = M.EquipItem

M.EquipItem.new = function(player, itemKind)
    return setmetatable({playerId = player.id,itemKind=itemKind},M.EquipItem)
end

M.EquipItem.serialize = function()
    return {Types.Messages.EQUIP,self.playerId,self.itemKind}
end

M.Drop = {}
M.Drop.__index = M.Drop
M.Drop.new = function(mob, item)
    return setmetatable({mob = mob,item=item},M.Drop)
end

M.Drop.serialize = function()
    local drop = {Types.Messages.DROP,
                self.mob.id,
                self.item.id,
                self.item.kind,
                _.pluck(self.mob.hatelist, "id")}

    return drop
end

M.Chat = {}
M.Chat.__index = M.Chat
M.Chat.new = function(player, message)
    return setmetatable({playerId = player.id,message=message},M.Chat)
end
M.Chat.serialize = function()
    return {Types.Messages.CHAT,self.playerId,self.message}
end

M.Teleport = {}
M.Teleport.__index = M.Teleport
M.Teleport.new = function(entity)
    return setmetatable({entity = entity},M.Teleport)

end
M.Teleport.serialize = function()
    return {Types.Messages.TELEPORT,self.entity.id,self.entity.x,self.entity.y}
end

M.Damage = {}
M.Damage.__index = M.Damage
M.Damage.new = function(entity, points)
    return setmetatable({entity = entity,points = points},M.Damage)
end

M.Damage.serialize = function()
    return {Types.Messages.DAMAGE,self.entity.id,self.points}
end

M.Population = {}
M.Population.__index = M.Population
M.Population.new = function(world, total)
    return setmetatable({world = world,total = total},M.Population)
end
M.Population.serialize = function()
    return {Types.Messages.POPULATION,self.world,self.total}
end

M.Kill = {}
M.Kill.__index = M.Kill
M.Kill.new = function(mob)
    return setmetatable({mob = mob},M.Kill)
end
M.Kill.serialize = function()
    return {Types.Messages.KILL,self.mob.kind}
end

M.List = {}
M.List.__index = M.List
M.List.new = function(ids)
    return setmetatable({ids = ids},M.List)
end
M.List.serialize = function()
    local list = self.ids
    
    list.unshift(Types.Messages.LIST)
    return list
end

M.Destroy = {}
M.Destroy.__index = M.Destroy
M.Destroy.new = function(entity)
    return setmetatable({entity = entity},M.Destroy)
end
M.Destroy.serialize = function()
    return {Types.Messages.DESTROY,self.entity.id}
end

M.Blink = {}
M.Blink.__index = M.Blink
M.Blink.new = function(item)
    return setmetatable({item = item},M.Blink)
end
M.Blink.serialize = function()
    return {Types.Messages.BLINK,self.item.id}
end

return M

