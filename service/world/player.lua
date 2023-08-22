local Types = require "share"
local Messages = require "message"
local Character = require "character"
local class = require "class"
local Formulas = require "formulas"
local Properties = require "propertites"
local Utils = require "utils"
local FormatChecker= require "format"

local M = class.Class(Character)

function M.new()
    local o = {}
    setmetatable(o,M)
    return o
end

function M:init(fd, worldServer)
    self.server = worldServer
    self.fd = fd

    M._base.init(self,fd, "player", Types.Entities.WARRIOR, 0, 0, "")

    self.hasEnteredGame = false
    self.isDead = false
    self.haters = {}
    self.lastCheckpoint = nil
    self.formatChecker = FormatChecker.new()
    self.disconnectTimeout = nil
    --self.connection.sendUTF8("go") -- Notify client that the HELLO/WELCOME handshake can start
    send_to_client(fd,"go")
end

function M:dispatchMessage(message)
    local action = tonumber(message[1])

        if not self.hasEnteredGame and action ~= Types.Messages.HELLO then -- HELLO must be the first message
            self.connection.close("Invalid handshake message: "+message)
            return
        end
        if self.hasEnteredGame and not self.isDead and action == Types.Messages.HELLO then -- HELLO can be sent only once
            self.connection.close("Cannot initiate handshake twice: "+message)
            return
        end
        
        self.resetTimeout()
        if action == Types.Messages.HELLO then
            -- If name was cleared by the sanitizer, give a default name.
            -- Always ensure that the name is not longer than a maximum length.
            -- (also enforced by the maxlength attribute of the name input element).
            self.name = message[2]
            
            self.kind = Types.Entities.WARRIOR
            self:equipArmor(message[3])
            self:equipWeapon(message[4])
            self.orientation = Utils.randomOrientation()
            self:updateHitPoints()
            self:updatePosition()

            self.server:addPlayer(self)
            self.server.enter_callback(self)

            self:send({Types.Messages.WELCOME, self.id, self.name, self.x, self.y, self.hitPoints})

            self.hasEnteredGame = true
            self.isDead = false
        elseif action == Types.Messages.WHO then
            table.remove(message,1)
            self.server:pushSpawnsToPlayer(self, message)
        elseif action == Types.Messages.ZONE then
            self:zone_callback()
        elseif action == Types.Messages.CHAT then
            local msg = Utils.sanitize(message[2])
            
            -- Sanitized messages may become empty. No need to broadcast empty chat messages.
            if msg and msg ~= "" then
                msg = msg.substr(0, 60) -- Enforce maxlength of chat input
                self:broadcastToZone(Messages.Chat.new(self, msg), false)
            end
        elseif action == Types.Messages.MOVE then
            if self.move_callback then
                local x = message[2]
                local y = message[3]
                
                if self.server:isValidPosition(x, y) then
                    self:setPosition(x, y)
                    self:clearTarget()
                    
                    self:broadcast(Messages.Move.new(self))
                    self.move_callback(self.x, self.y)
                end
            end
        elseif action == Types.Messages.LOOTMOVE then
            if self.lootmove_callback then
                self:setPosition(message[2], message[3])
                
                local item = self.server.getEntityById(message[4])
                if item then
                    self:clearTarget()

                    self:broadcast(Messages.LootMove.new(self, item))
                    self.lootmove_callback(self.x, self.y)
                end
            end
        elseif action == Types.Messages.AGGRO then
            if self.move_callback then
                self.server:handleMobHate(message[2], self.id, 5)
            end
        elseif action == Types.Messages.ATTACK then
            local mob = self.server:getEntityById(message[2])
            
            if mob then
                self:setTarget(mob)
                self.server:broadcastAttacker(self)
            end
        elseif action == Types.Messages.HIT then
            local mob = self.server:getEntityById(message[2])
            if mob then
                local dmg = Formulas.dmg(self.weaponLevel, mob.armorLevel)
                
                if dmg > 0 then
                    mob:receiveDamage(dmg, self.id)
                    self.server:handleMobHate(mob.id, self.id, dmg)
                    self.server:handleHurtEntity(mob, self, dmg)
                end
            end
        elseif action == Types.Messages.HURT then
            local mob = self.server:getEntityById(message[2])
            if mob and self.hitPoints > 0 then
                self.hitPoints = self.hitPoints - Formulas.dmg(mob.weaponLevel, self.armorLevel)
                self.server:handleHurtEntity(self)
                
                if self.hitPoints <= 0 then
                    self.isDead = true
                    if self.firepotionTimeout then
                        clearTimeout(self.firepotionTimeout)
                    end
                end
            end
        elseif action == Types.Messages.LOOT then
            local item = self.server:getEntityById(message[2])
            
            if item then
                local kind = item.kind
                
                if Types.isItem(kind) then
                    self:broadcast(item.despawn())
                    self.server:removeEntity(item)
                    
                    if kind == Types.Entities.FIREPOTION then
                        self:updateHitPoints()
                        self:broadcast(self.equip(Types.Entities.FIREFOX))
                        self.firepotionTimeout = setTimeout(function()
                            self:broadcast(self.equip(self.armor)) -- return to normal after 15 sec
                            self.firepotionTimeout = nil
                        end,15000)
                        self:send(Messages.HitPoints.new(self.maxHitPoints).serialize())
                    elseif Types.isHealingItem(kind) then
                        local amount
                        
                        if kind == Types.Entities.FLASK then
                                amount = 40
                        elseif kind == Types.Entities.BURGER then
                                amount = 100
                        end
                        
                        if not self:hasFullHealth() then
                            self:regenHealthBy(amount)
                            self.server:pushToPlayer(self, self.health())
                        end
                    elseif Types.isArmor(kind) or Types.isWeapon(kind) then
                        self:equipItem(item)
                        self:broadcast(self:equip(kind))
                    end
                end
            end
        elseif action == Types.Messages.TELEPORT then
            local x = message[2]
            local y = message[3]
            
            if self.server.isValidPosition(x, y) then
                self:setPosition(x, y)
                self:clearTarget()
                
                self:broadcast(Messages.Teleport.new(self))
                
                self.server:handlePlayerVanish(self)
                self.server:pushRelevantEntityListTo(self)
            end
        elseif action == Types.Messages.OPEN then
            local chest = self.server:getEntityById(message[2])
            if chest  then --and chest instanceof Chest then
                self.server:handleOpenedChest(chest, self)
            end
        elseif action == Types.Messages.CHECK then
            local checkpoint = self.server.map:getCheckpoint(message[2])
            if checkpoint then
                self.lastCheckpoint = checkpoint
            end
        else
            if self.message_callback then
                self:message_callback(message)
            end
        end
end

function M:onClose()
    print("on close haha")
    if self.firepotionTimeout then
        clearTimeout(self.firepotionTimeout)
    end
    clearTimeout(self.disconnectTimeout)
    if self.exit_callback then
        self.exit_callback()
    end
end

function M:destroy()
    self:forEachAttacker(function(mob)
        mob:clearTarget()
    end)
    self.attackers = {}
    
    self.forEachHater(function(mob)
        mob:forgetPlayer(self.id)
    end)
    self.haters = {}
end

function M:getState()
    local basestate = self:_getBaseState()
    local state = {self.name, self.orientation, self.armor, self.weapon}

    if self.target then
        table.insert(state,self.target)
    end
    
    return basestate.concat(state)
end

function M:send(message)
    send_to_client(self.fd,message)
end

function M:broadcast(message, ignoreSelf)
    if self.broadcast_callback then
        self:broadcast_callback(message, ignoreSelf == nil and true or ignoreSelf)
    end
end

function M:broadcastToZone(message, ignoreSelf)
    if self.broadcastzone_callback then
        self:broadcastzone_callback(message, ignoreSelf == nil and true or ignoreSelf)
    end
end

function M:onExit(callback)
    self.exit_callback = callback
end

function M:onMove(callback)
    self.move_callback = callback
end

function M:onLootMove(callback)
    self.lootmove_callback = callback
end

function M:onZone(callback)
    self.zone_callback = callback
end

function M:onOrient(callback)
    self.orient_callback = callback
end

function M:onMessage(callback)
    self.message_callback = callback
end

function M:onBroadcast(callback)
    self.broadcast_callback = callback
end

function M:onBroadcastToZone(callback)
    self.broadcastzone_callback = callback
end

function M:equip(item)
    return Messages.EquipItem.new(self, item)
end

function M:addHater(mob)
    self.haters[mob.id] = mob
end

function M:removeHater(mob)
    self.haters[mob.id] = nil
end

function M:forEachHater(callback)
    for _,mob in pairs(self.haters) do
        callback(mob)
    end
end

function M:equipArmor(kind)
    self.armor = kind
    self.armorLevel = Properties.getArmorLevel(kind)
end

function M:equipWeapon(kind)
    self.weapon = kind
    self.weaponLevel = Properties.getWeaponLevel(kind)
end

function M:equipItem(item)
    if item then
        --log.debug(self.name + " equips " + Types.getKindAsString(item.kind))
        
        if Types.isArmor(item.kind) then
            self:equipArmor(item.kind)
            self:updateHitPoints()
            self:send(Messages.HitPoints.new(self.maxHitPoints).serialize())
        elseif Types.isWeapon(item.kind) then
            self:equipWeapon(item.kind)
        end
    end
end

function M:updateHitPoints()
    self:resetHitPoints(Formulas.hp(self.armorLevel))
end

function M:updatePosition()
    if self.requestpos_callback then
        local pos = self.requestpos_callback()
        self:setPosition(pos.x, pos.y)
    end
end

function M:onRequestPosition(callback)
    self.requestpos_callback = callback
end

function M:resetTimeout()
end

function M:timeout()
    self.connection.sendUTF8("timeout")
    self.connection.close("Player was idle for too long")
end

return M