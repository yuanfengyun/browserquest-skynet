
local cls = require("class")
local Entity = require('entity')
local Character = require('character')
local Mob = require('mob')
local Map = require('map')
local Npc = require('npc')
local Player = require('player')
local Item = require('item')
local MobArea = require('mobarea')
local ChestArea = require('chestarea')
local Chest = require('chest')
local Messages = require('message')
local Properties = require("propertites")
local Utils = require("utils")
local Types = require("share")

local M = cls.Class()

function M.new(id, maxPlayers)
    local o = setmetatable({},M)
    o:init(id,maxPlayers)
    return o
end

function M:init(id, maxPlayers, websocketServer)
    self.id = id
    self.maxPlayers = maxPlayers
    self.server = websocketServer
    self.ups = 50
    
    self.map = nil
    
    self.entities = {}
    self.players = {}
    self.mobs = {}
    self.attackers = {}
    self.items = {}
    self.equipping = {}
    self.hurt = {}
    self.npcs = {}
    self.mobAreas = {}
    self.chestAreas = {}
    self.groups = {}
    
    self.outgoingQueues = {}
    
    self.itemCount = 0
    self.playerCount = 0
    
    self.zoneGroupsReady = false
    
    self:onPlayerConnect(function(player)
        player:onRequestPosition(function()
            if player.lastCheckpoint then
                return player.lastCheckpoint:getRandomPosition()
            else
                return self.map:getRandomStartingPosition()
            end
        end)
    end)
    
    self:onPlayerEnter(function(player)
        print(player.name .. " has joined ".. self.id)
        
        if not player.hasEnteredGame then
            self:incrementPlayerCount()
        end
        
        -- Number of players in this world
        self:pushToPlayer(player, Messages.Population.new(self.playerCount))
        self:pushRelevantEntityListTo(player)

        local move_callback = function(x, y)
            print(player.name .. " is moving to (" .. x .. ", " .. y .. ").")
            
            player:forEachAttacker(function(mob)
                local target = self:getEntityById(mob.target)
                if(target) then
                    local pos = self:findPositionNextTo(mob, target)
                    if(mob:distanceToSpawningPoint(pos.x, pos.y) > 50) then
                        mob:clearTarget()
                        mob:forgetEveryone()
                        player:removeAttacker(mob)
                    else
                        self:moveEntity(mob, pos.x, pos.y)
                    end
                end
            end)
        end
        player:onMove(move_callback)
        player:onLootMove(move_callback)
        
        player:onZone(function()
            local hasChangedGroups = self:handleEntityGroupMembership(player)
            
            if hasChangedGroups then
                self:pushToPreviousGroups(player, Messages.Destroy.new(player))
                self:pushRelevantEntityListTo(player)
            end
        end)

        player:onBroadcast(function(message, ignoreSelf)
            self:pushToAdjacentGroups(player.group, ifmessage, ignoreSelf and player.id or nil)
        end)
        
        player:onBroadcastToZone(function(message, ignoreSelf)
            self:pushToGroup(player.group, message, ignoreSelf and player.id or nil)
        end)

        player:onExit(function()
            --log.info(player.name + " has left the game.")
            self:removePlayer(player)
            self:decrementPlayerCount()
            
            if self.removed_callback then
                self:removed_callback()
            end
        end)
        
        if self.added_callback then
            self:added_callback()
        end
    end)
    
    -- Called when an entity is attacked by another entity
    self:onEntityAttack(function(attacker)
        local target = self:getEntityById(attacker.target)
        if(target and attacker.type == "mob") then
            local pos = self:findPositionNextTo(attacker, target)
            self:moveEntity(attacker, pos.x, pos.y)
        end
    end)
    
    self:onRegenTick(function()
        self:forEachCharacter(function(character)
            if(not character:hasFullHealth()) then
                character:regenHealthBy(Math.floor(character.maxHitPoints / 25))
        
                if(character.type == 'player') then
                    self:pushToPlayer(character, character.regen())
                end
            end
        end)
    end)
end

function M:run(mapFilePath)
    
    self.map = Map.new(mapFilePath)

    self.map:ready(function()
        self:initZoneGroups()
        
        self.map:generateCollisionGrid()
        
        -- Populate all mob "roaming" areas
        each(self.map.mobAreas, function(a)
            local area = MobArea.new(a.id, a.nb, a.type, a.x, a.y, a.width, a.height, self)
            area:spawnMobs()
            area:onEmpty(function() self:handleEmptyMobArea(area) end)
            
            table.insert(self.mobAreas,area)
        end)
        
        -- Create all chest areas
        each(self.map.chestAreas, function(a)
            local area = ChestArea.new(a.id, a.x, a.y, a.w, a.h, a.tx, a.ty, a.i, self)
            table.insert(self.chestAreas,area)
            area:onEmpty(function() self:handleEmptyChestArea(area) end)
        end)
        
        -- Spawn static chests
        each(self.map.staticChests, function(chest)
            local c = self:createChest(chest.x, chest.y, chest.i)
            self:addStaticItem(c)
        end)
        
        -- Spawn static entities
        self:spawnStaticEntities()
        
        -- Set maximum number of entities contained in each chest area
        each(self.chestAreas, function(area)
            area:setNumberOfEntities(area.entities.length)
        end)
    end)
    
    local regenCount = self.ups * 2
    local updateCount = 0
    setInterval(function()
        self:processGroups()
        self:processQueues()
        
        if(updateCount < regenCount) then
            updateCount = updateCount + 1
        else
            if(self.regen_callback) then
                self.regen_callback()
            end
            updateCount = 0
        end
    end, 1000 / self.ups)
    
    print(""..self.id .. " created (capacity= " .. self.maxPlayers .. " players).")
end

function M:setUpdatesPerSecond(ups)
    self.ups = ups
end

function M:onInit(callback)
    self.init_callback = callback
end

function M:onPlayerConnect(callback)
    self.connect_callback = callback
end

function M:onPlayerEnter(callback)
    self.enter_callback = callback
end

function M:onPlayerAdded(callback)
    self.added_callback = callback
end

function M:onPlayerRemoved(callback)
    self.removed_callback = callback
end

function M:onRegenTick(callback)
    self.regen_callback = callback
end

function M:pushRelevantEntityListTo(player)
    local entities
    if player and inin(player.group,self.groups) then
        entities = keys(self.groups[player.group].entities)
        entities = reject(entities, function(id) return id == player.id end)
        if entities then
            self:pushToPlayer(player, Messages.List.new(entities))
        end
    end
end

function M:pushSpawnsToPlayer(player, ids)
    
    each(ids, function(id)
        local entity = self:getEntityById(id)
        if(entity) then
            self:pushToPlayer(player, Messages.Spawn.new(entity))
        end
    end)
    
    --log.debug("Pushed "+_.size(ids)+" new spawns to "+player.id)
end

function M:pushToPlayer(player, message)
    if(player and inin(player.id , self.outgoingQueues))then
        table.insert(self.outgoingQueues[player.id],message.serialize())
    else
        --log.error("pushToPlayer= player was undefined")
    end
end

function M:pushToGroup(groupId, message, ignoredPlayer)
    group = self.groups[groupId]
    if(group) then
        each(group.players, function(playerId)
            if(playerId ~= ignoredPlayer)then
                self:pushToPlayer(self.getEntityById(playerId), message)
            end
        end)
    else
        --log.error("groupId= "+groupId+" is not a valid group")
    end
end

function M:pushToAdjacentGroups(groupId, message, ignoredPlayer)
    self.map:forEachAdjacentGroup(groupId, function(id)
        self:pushToGroup(id, message, ignoredPlayer)
    end)
end

function M:pushToPreviousGroups(player, message)
    
    -- Push this message to all groups which are not going to be updated anymore,
    -- since the player left them.
    each(player.recentlyLeftGroups, function(id)
        self:pushToGroup(id, message)
    end)
    player.recentlyLeftGroups = {}
end

function M:pushBroadcast(message, ignoredPlayer)
    for id,_ in ipairs( self.outgoingQueues) do
        if(id ~= ignoredPlayer) then
            table.insert(self.outgoingQueues[id],message.serialize())
        end
    end
end

function M:processQueues()
    local connection

    for id,_ in ipairs(self.outgoingQueues) do
        if(self.outgoingQueues[id].length > 0) then
            send_to_player(id,self.outgoingQueues[id])
            self.outgoingQueues[id] = {}
        end
    end
end

function M:addEntity(entity)
    self.entities[entity.id] = entity
    self:handleEntityGroupMembership(entity)
end

function M:removeEntity(entity)
    if( self.entities[entity.id]) then
        self.entities[entity.id] = nil
    end
    if( self.mobs[entity.id]) then
        self.mobs[entity.id] = nil
    end
    if(self.items[entity.id]) then
        self.items[entity.id] = nil
    end
    
    if(entity.type == "mob") then
        self:clearMobAggroLink(entity)
        self:clearMobHateLinks(entity)
    end
    
    entity:destroy()
    self:removeFromGroups(entity)
    --slog.debug("Removed "+ Types.getKindAsString(entity.kind) +" = "+ entity.id)
end

function M:addPlayer(player)
    self:addEntity(player)
    self.players[player.id] = player
    self.outgoingQueues[player.id] = {}
    
    -- log.info("Added player = " + player.id)
end

function M:removePlayer(player)
    player:broadcast(player.despawn())
    self:removeEntity(player)
    self.players[player.id] = nil
    self.outgoingQueues[player.id] = nil
end

function M:addMob(mob)
    self:addEntity(mob)
    self.mobs[mob.id] = mob
end

function M:addNpc(kind, x, y)
    local npc = Npc.new('8' .. x ..'' .. y, kind, x, y)
    self:addEntity(npc)
    self.npcs[npc.id] = npc
    
    return npc
end

function M:addItem(item)
    self:addEntity(item)
    self.items[item.id] = item
    
    return item
end

function M:createItem(kind, x, y)
    local id = '9' .. self.itemCount
    self.itemCount = self.itemCount + 1
    local item
    
    if kind == Types.Entities.CHEST then
        item = Chest.new(id, x, y)
    else
        item = Item.new(id, kind, x, y)
    end
    return item
end

function M:createChest(x, y, items)
    local chest = self:createItem(Types.Entities.CHEST, x, y)
    chest:setItems(items)
    return chest
end

function M:addStaticItem(item)
    item.isStatic = true
    item:onRespawn(function() self:addStaticItem(item) end)
    
    return self:addItem(item)
end

function M:addItemFromChest(kind, x, y)
    local item = self:createItem(kind, x, y)
    item.isFromChest = true
    
    return self:addItem(item)
end

--The mob will no longer be registered as an attacker of its current target.
function M:clearMobAggroLink(mob)
    local player = null
    if(mob.target) then
        player = self:getEntityById(mob.target)
        if(player) then
            player:removeAttacker(mob)
        end
    end
end

function M:clearMobHateLinks(mob)
    if(mob) then
        each(mob.hatelist, function(obj)
            local player = self:getEntityById(obj.id)
            if(player) then
                player:removeHater(mob)
            end
        end)
    end
end

function M:forEachEntity(callback)
    for id,_ in pairs(self.entities) do
        callback(self.entities[id])
    end
end

function M:forEachPlayer(callback)
    for id,_ in pairs(self.players) do
        callback(self.players[id])
    end
end

function M:forEachMob(callback)
    for id,_ in pairs(self.mobs) do
        callback(self.mobs[id])
    end
end

function M:forEachCharacter (callback)
    self:forEachPlayer(callback)
    self:forEachMob(callback)
end

function M:handleMobHate(mobId, playerId, hatePoints)
    local mob = self:getEntityById(mobId)
    local player = self:getEntityById(playerId)
    local mostHated
    
    if player and mob then
        mob:increaseHateFor(playerId, hatePoints)
        player:addHater(mob)
        
        if(mob.hitPoints > 0) then -- only choose a target if still alive
            self:chooseMobTarget(mob)
        end
    end
end

function M:chooseMobTarget(mob, hateRank)
    local player = self:getEntityById(mob.getHatedPlayerId(hateRank))
    
    -- If the mob is not already attacking the player, create an attack link between them.
    if(player and not inin(mob.id ,player.attackers)) then
        self:clearMobAggroLink(mob)
        
        player:addAttacker(mob)
        mob:setTarget(player)
        
        self:broadcastAttacker(mob)
        --log.debug(mob.id + " is now attacking " + player.id)
    end
end

function M:onEntityAttack(callback)
    self.attack_callback = callback
end

function M:getEntityById(id)
    if inin(id,self.entities) then
        return self.entities[id]
    else
        --log.error("Unknown entity = " + id)
    end
end

function M:getPlayerCount()
    local count = 0
    for p,_ in pairs(self.players) do
        if(self.players:hasOwnProperty(p)) then
            count = count + 1
        end
    end
    return count
end

function M:broadcastAttacker(character)
    if(character)then
        self:pushToAdjacentGroups(character.group, character.attack(), character.id)
    end
    if(self.attack_callback) then
        self:attack_callback(character)
    end
end

function M:handleHurtEntity(entity, attacker, damage)
    
    if(entity.type == 'player') then
        -- A player is only aware of his own hitpoints
        self:pushToPlayer(entity, entity:health())
    end
    
    if(entity.type == 'mob') then
        -- Let the mob's attacker (player) know how much damage was inflicted
        self:pushToPlayer(attacker, Messages.Damage.new(entity, damage))
    end

    -- If the entity is about to die
    if entity.hitPoints <= 0 then
        if entity.type == "mob" then
            local mob = entity
            local item = self:getDroppedItem(mob)

            self:pushToPlayer(attacker, Messages.Kill.new(mob))
            self:pushToAdjacentGroups(mob.group, mob:despawn()) -- Despawn must be enqueued before the item drop
            if item then
                self:pushToAdjacentGroups(mob.group, mob:drop(item))
                self:handleItemDespawn(item)
            end
        end

        if entity.type == "player" then
            self:handlePlayerVanish(entity)
            self:pushToAdjacentGroups(entity.group, entity:despawn())
        end

        self:removeEntity(entity)
    end
end

function M:despawn(entity)
    self:pushToAdjacentGroups(entity.group, entity:despawn())

    if inin(entity.id , self.entities) then
        self:removeEntity(entity)
    end
end

function M:spawnStaticEntities()
    local count = 0
    
    each(self.map.staticEntities, function(kindName, tid)
        local kind = Types.getKindFromString(kindName)
        local pos = self.map:tileIndexToGridPosition(tid)
        
        if Types.isNpc(kind) then
            self:addNpc(kind, pos.x + 1, pos.y)
        end
        if Types.isMob(kind) then
            local mob = Mob.new('7' .. kind .. count, kind, pos.x + 1, pos.y)
            count = count + 1
            mob:onRespawn(function()
                mob.isDead = false
                self:addMob(mob)
                if mob.area and instanceof(mob.area ,ChestArea) then
                    mob.area:addToArea(mob)
                end
            end)
            mob:onMove(function() self:onMobMoveCallback(self) end)
            self:addMob(mob)
            self:tryAddingMobToChestArea(mob)
        end
        if Types.isItem(kind) then
            self:addStaticItem(self:createItem(kind, pos.x + 1, pos.y))
        end
    end)
end

function M:isValidPosition(x, y)
    if self.map and isNumber(x) and isNumber(y) and not self.map:isOutOfBounds(x, y) and not self.map:isColliding(x, y) then
        return true
    end
    return false
end

function M:handlePlayerVanish(player)
    local previousAttackers = {}
    
    -- When a player dies or teleports, all of his attackers go and attack their second most hated player.
    player:forEachAttacker(function(mob)
        table.insert(previousAttackers,mob)
        self:chooseMobTarget(mob, 2)
    end)
    
    each(previousAttackers, function(mob)
        player:removeAttacker(mob)
        mob:clearTarget()
        mob:forgetPlayer(player.id, 1000)
    end)
    
    self:handleEntityGroupMembership(player)
end

function M:setPlayerCount(count)
    self.playerCount = count
end

function M:incrementPlayerCount()
    self:setPlayerCount(self.playerCount + 1)
end

function M:decrementPlayerCount()
    if(self.playerCount > 0) then
        self:setPlayerCount(self.playerCount - 1)
    end
end

function M:getDroppedItem(mob)
    local kind = Types.getKindAsString(mob.kind)
    local drops = Properties[kind].drops
    local v = Utils.random(100)
    local p = 0
    local item = nil
    
    for itemName,_ in pairs(drops) do
        local percentage = drops[itemName]
        
        p = p + percentage
        if(v <= p) then
            item = self:addItem(self.createItem(Types.getKindFromString(itemName), mob.x, mob.y))
            break
        end
    end
    
    return item
end

function M:onMobMoveCallback(mob)
    self:pushToAdjacentGroups(mob.group, Messages.Move.new(mob))
    self:handleEntityGroupMembership(mob)
end

function M:findPositionNextTo(entity, target)
    local valid = false
    local pos
    
    while(not valid) do
        pos = entity:getPositionNextTo(target)
        valid = self:isValidPosition(pos.x, pos.y)
    end
    return pos
end

function M:initZoneGroups()
    
    self.map:forEachGroup(function(id)
        self.groups[id] = { entities= {},
                            players= {},
                            incoming= {}}
    end)
    self.zoneGroupsReady = true
end

function M:removeFromGroups(entity)
    local oldGroups = {}
    
    if(entity and entity.group)then
        
        local group = self.groups[entity.group]
        if instanceof(entity,Player) then
            group.players = reject(group.players, function(id) return id == entity.id end)
        end
        
        self.map:forEachAdjacentGroup(entity.group, function(id)
            if inin(entity.id, self.groups[id].entities) then
                self.groups[id].entities[entity.id] = nil
                table.insert(oldGroups,id)
            end
        end)
        entity.group = null
    end
    return oldGroups
end

--Registers an entity as "incoming" into several groups, meaning that it just entered them.
--All players inside these groups will receive a Spawn message when WorldServer.processGroups is called.
function M:addAsIncomingToGroup(entity, groupId)
    local isChest = entity and instanceof(entity,  Chest)
    local isItem = entity and instanceof(entity , Item)
    local isDroppedItem =  entity and isItem and not entity.isStatic and not entity.isFromChest
    
    if entity and groupId then
        self.map:forEachAdjacentGroup(groupId, function(id)
            local group = self.groups[id]
            
            if(group)then
                if(not include(group.entities, entity.id)
                --  Items dropped off of mobs are handled differently via DROP messages. See handleHurtEntity.
                and (not isItem or isChest or (isItem and not isDroppedItem))) then
                    table.insert(group.incoming,entity)
                end
            end
        end)
    end
end

function M:addToGroup(entity, groupId)
    local newGroups = {}
    if entity and groupId and inin(groupId ,self.groups) then
        self.map:forEachAdjacentGroup(groupId, function(id)
            self.groups[id].entities[entity.id] = entity
            table.insert(newGroups,id)
        end)
        entity.group = groupId
        
        if instanceof(entity,  Player)then
            table.insert(self.groups[groupId].players,entity.id)
        end
    end
    return newGroups
end

function M:logGroupPlayers(groupId)
    --log.debug("Players inside group "+groupId+":")
    each(self.groups[groupId].players, function(id)
        --log.debug("- player "+id)
    end)
end

function M:handleEntityGroupMembership(entity)
    local hasChangedGroups = false
    if entity then
        local groupId = self.map:getGroupIdFromPosition(entity.x, entity.y)
        if not entity.group or (entity.group and entity.group ~= groupId) then
            hasChangedGroups = true
            self:addAsIncomingToGroup(entity, groupId)
            local oldGroups = self:removeFromGroups(entity)
            local newGroups = self:addToGroup(entity, groupId)
            
            if(#oldGroups > 0) then
                entity.recentlyLeftGroups = difference(oldGroups, newGroups)
                --log.debug("group diff= " + entity.recentlyLeftGroups)
            end
        end
    end
    return hasChangedGroups
end

function M:processGroups()

    if(self.zoneGroupsReady)then
        self.map:forEachGroup(function(id)
            local spawns = {}
            if(#self.groups[id].incoming > 0) then
                spawns = each(self.groups[id].incoming, function(entity)
                    if instanceof(entity,  Player)then
                        self:pushToGroup(id, Messages.Spawn.new(entity), entity.id)
                    else
                        self:pushToGroup(id, Messages.Spawn.new(entity))
                    end
                end)
                self.groups[id].incoming = {}
            end
        end)
    end
end

function M:moveEntity(entity, x, y)
    if entity then
        entity:setPosition(x, y)
        self:handleEntityGroupMembership(entity)
    end
end

function M:handleItemDespawn(item)
    
    if(item)then
        item.handleDespawn({
            beforeBlinkDelay= 10000,
            blinkCallback= function()
                self:pushToAdjacentGroups(item.group, Messages.Blink.new(item))
            end,
            blinkingDuration= 4000,
            despawnCallback= function()
                self:pushToAdjacentGroups(item.group, Messages.Destroy.new(item))
                self:removeEntity(item)
            end
        })
    end
end

function M:handleEmptyMobArea(area)

end

function M:handleEmptyChestArea(area)
    if(area) then
        local chest = self:addItem(self:createChest(area.chestX, area.chestY, area.items))
        self:handleItemDespawn(chest)
    end
end

function M:handleOpenedChest(chest, player)
    self:pushToAdjacentGroups(chest.group, chest:despawn())
    self:removeEntity(chest)
    
    local kind = chest:getRandomItem()
    if(kind) then
        local item = self:addItemFromChest(kind, chest.x, chest.y)
        self:handleItemDespawn(item)
    end
end

function M:tryAddingMobToChestArea(mob)
    each(self.chestAreas, function(area)
        if area:contains(mob) then
            area:addToArea(mob)
        end
    end)
end

function M:updatePopulation(totalPlayers)
    self:pushBroadcast(Messages.Population.new(self.playerCount, totalPlayers and totalPlayers or self.playerCount))
end

return M

