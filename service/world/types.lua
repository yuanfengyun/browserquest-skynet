local M = {}

M.Messages = {
    HELLO= 0,
    WELCOME= 1,
    SPAWN= 2,
    DESPAWN= 3,
    MOVE= 4,
    LOOTMOVE= 5,
    AGGRO= 6,
    ATTACK= 7,
    HIT= 8,
    HURT= 9,
    HEALTH= 10,
    CHAT= 11,
    LOOT= 12,
    EQUIP= 13,
    DROP= 14,
    TELEPORT= 15,
    DAMAGE= 16,
    POPULATION= 17,
    KILL= 18,
    LIST= 19,
    WHO= 20,
    ZONE= 21,
    DESTROY= 22,
    HP= 23,
    BLINK= 24,
    OPEN= 25,
    CHECK= 26
}
    
M.Entities= {
    WARRIOR= 1,
    
    -- Mobs
    RAT= 2,
    SKELETON= 3,
    GOBLIN= 4,
    OGRE= 5,
    SPECTRE= 6,
    CRAB= 7,
    BAT= 8,
    WIZARD= 9,
    EYE= 10,
    SNAKE= 11,
    SKELETON2= 12,
    BOSS= 13,
    DEATHKNIGHT= 14,
    
    -- Armors
    FIREFOX= 20,
    CLOTHARMOR= 21,
    LEATHERARMOR= 22,
    MAILARMOR= 23,
    PLATEARMOR= 24,
    REDARMOR= 25,
    GOLDENARMOR= 26,
    
    -- Objects
    FLASK= 35,
    BURGER= 36,
    CHEST= 37,
    FIREPOTION= 38,
    CAKE= 39,
        
    -- NPCs
    GUARD= 40,
    KING= 41,
    OCTOCAT= 42,
    VILLAGEGIRL= 43,
    VILLAGER= 44,
    PRIEST= 45,
    SCIENTIST= 46,
    AGENT= 47,
    RICK= 48,
    NYAN= 49,
    SORCERER= 50,
    BEACHNPC= 51,
    FORESTNPC= 52,
    DESERTNPC= 53,
    LAVANPC= 54,
    CODER= 55,
    
    -- Weapons
    SWORD1= 60,
    SWORD2= 61,
    REDSWORD= 62,
    GOLDENSWORD= 63,
    MORNINGSTAR= 64,
    AXE= 65,
    BLUESWORD= 66
}
    
M.Orientations= {
    UP= 1,
    DOWN= 2,
    LEFT= 3,
    RIGHT= 4
}

local kinds = {
    warrior= {M.Entities.WARRIOR, "player"},
    
    rat= {M.Entities.RAT, "mob"},
    skeleton= {M.Entities.SKELETON , "mob"},
    goblin= {M.Entities.GOBLIN, "mob"},
    ogre= {M.Entities.OGRE, "mob"},
    spectre= {M.Entities.SPECTRE, "mob"},
    deathknight= {M.Entities.DEATHKNIGHT, "mob"},
    crab= {M.Entities.CRAB, "mob"},
    snake= {M.Entities.SNAKE, "mob"},
    bat= {M.Entities.BAT, "mob"},
    wizard= {M.Entities.WIZARD, "mob"},
    eye= {M.Entities.EYE, "mob"},
    skeleton2= {M.Entities.SKELETON2, "mob"},
    boss= {M.Entities.BOSS, "mob"},

    sword1= {M.Entities.SWORD1, "weapon"},
    sword2= {M.Entities.SWORD2, "weapon"},
    axe= {M.Entities.AXE, "weapon"},
    redsword= {M.Entities.REDSWORD, "weapon"},
    bluesword= {M.Entities.BLUESWORD, "weapon"},
    goldensword= {M.Entities.GOLDENSWORD, "weapon"},
    morningstar= {M.Entities.MORNINGSTAR, "weapon"},
    
    firefox= {M.Entities.FIREFOX, "armor"},
    clotharmor= {M.Entities.CLOTHARMOR, "armor"},
    leatherarmor= {M.Entities.LEATHERARMOR, "armor"},
    mailarmor= {M.Entities.MAILARMOR, "armor"},
    platearmor= {M.Entities.PLATEARMOR, "armor"},
    redarmor= {M.Entities.REDARMOR, "armor"},
    goldenarmor= {M.Entities.GOLDENARMOR, "armor"},

    flask= {M.Entities.FLASK, "object"},
    cake= {M.Entities.CAKE, "object"},
    burger= {M.Entities.BURGER, "object"},
    chest= {M.Entities.CHEST, "object"},
    firepotion= {M.Entities.FIREPOTION, "object"},

    guard= {M.Entities.GUARD, "npc"},
    villagegirl= {M.Entities.VILLAGEGIRL, "npc"},
    villager= {M.Entities.VILLAGER, "npc"},
    coder= {M.Entities.CODER, "npc"},
    scientist= {M.Entities.SCIENTIST, "npc"},
    priest= {M.Entities.PRIEST, "npc"},
    king= {M.Entities.KING, "npc"},
    rick= {M.Entities.RICK, "npc"},
    nyan= {M.Entities.NYAN, "npc"},
    sorcerer= {M.Entities.SORCERER, "npc"},
    agent= {M.Entities.AGENT, "npc"},
    octocat= {M.Entities.OCTOCAT, "npc"},
    beachnpc= {M.Entities.BEACHNPC, "npc"},
    forestnpc= {M.Entities.FORESTNPC, "npc"},
    desertnpc= {M.Entities.DESERTNPC, "npc"},
    lavanpc= {M.Entities.LAVANPC, "npc"},
    
    getType= function(kind)
        return kinds[M.getKindAsString(kind)][1]
    end
}

M.rankedWeapons = {
    M.Entities.SWORD1,
    M.Entities.SWORD2,
    M.Entities.AXE,
    M.Entities.MORNINGSTAR,
    M.Entities.BLUESWORD,
    M.Entities.REDSWORD,
    M.Entities.GOLDENSWORD
}

M.rankedArmors = {
    M.Entities.CLOTHARMOR,
    M.Entities.LEATHERARMOR,
    M.Entities.MAILARMOR,
    M.Entities.PLATEARMOR,
    M.Entities.REDARMOR,
    M.Entities.GOLDENARMOR
}

function M.getWeaponRank(weaponKind)
    return indexOf(M.rankedWeapons, weaponKind)
end

function M.getArmorRank(armorKind)
    return indexOf(M.rankedArmors, armorKind)
end

function M.isPlayer(kind)
    return kinds.getType(kind) == "player"
end

function M.isMob(kind)
    return kinds.getType(kind) == "mob"
end

function M.isNpc(kind)
    return kinds.getType(kind) == "npc"
end

function M.isCharacter(kind)
    return M.isMob(kind) or M.isNpc(kind) or M.isPlayer(kind)
end

function M.isArmor(kind)
    return kinds.getType(kind) == "armor"
end

function M.isWeapon(kind)
    return kinds.getType(kind) == "weapon"
end


function M.isObject(kind)
    return kinds.getType(kind) == "object"
end

function M.isChest(kind)
    return kind == M.Entities.CHEST
end

function M.isItem(kind)
    return M.isWeapon(kind) 
        or M.isArmor(kind) 
        or (M.isObject(kind) and ~M.isChest(kind))
end

function M.isHealingItem(kind)
    return kind == M.Entities.FLASK 
        or kind == M.Entities.BURGER
end

function M.isExpendableItem(kind)
    return M.isHealingItem(kind)
        or kind == M.Entities.FIREPOTION
        or kind == M.Entities.CAKE
end

function M.getKindFromString(kind)
    for kind,v in pairs(kinds) do
        return v[0]
    end
end

function M.getKindAsString(kind)
    for k,v in pairs(kinds) do
        if v[0] == kind then
            return k
        end
    end
end

function M.forEachKind(callback)
    for k,v in pairs(kinds) do
        callback(v[0], k)
    end
end

function M.forEachArmor(callback)
    M.forEachKind(function(kind, kindName)
        if M.isArmor(kind) then
            callback(kind, kindName)
        end
    end)
end

function M.forEachMobOrNpcKind(callback)
    M.forEachKind(function(kind, kindName)
        if M.isMob(kind) or M.isNpc(kind) then
            callback(kind, kindName)
        end
    end)
end

function M.forEachArmorKind(callback)
    M.forEachKind(function(kind, kindName)
        if M.isArmor(kind) then
            callback(kind, kindName)
        end
    end)
end

function M.getOrientationAsString(orientation)
    if M.Orientations.LEFT == orientation then
        return "left"
    elseif M.Orientations.RIGHT == orientation then
        return "right"
    elseif M.Orientations.UP == orientation then
        return "up"
    elseif M.Orientations.DOWN == orientation then
        return "down"
    end
end

function M.getRandomItemKind(item)
    local all = union(this.rankedWeapons, this.rankedArmors)
        forbidden = {M.Entities.SWORD1, M.Entities.CLOTHARMOR}
        itemKinds = difference(all, forbidden)
        i = Math.floor(Math.random() * size(itemKinds))
    
    return itemKinds[i]
end

function M.getMessageTypeAsString (type)
    local typeName
    for k,v in pairs(M.Messages) do
        if v == type then
            typeName = k
        end
    end
    return typeName or "UNKNOWN"
end

return M