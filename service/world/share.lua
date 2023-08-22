
local Types = {
    Messages = {
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
    },
    
    Entities= {
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
    },
    
    Orientations= {
        UP= 1,
        DOWN= 2,
        LEFT= 3,
        RIGHT= 4
    }
}

local kinds = {
    warrior= {Types.Entities.WARRIOR, "player"},
    
    rat= {Types.Entities.RAT, "mob"},
    skeleton= {Types.Entities.SKELETON , "mob"},
    goblin= {Types.Entities.GOBLIN, "mob"},
    ogre= {Types.Entities.OGRE, "mob"},
    spectre= {Types.Entities.SPECTRE, "mob"},
    deathknight= {Types.Entities.DEATHKNIGHT, "mob"},
    crab= {Types.Entities.CRAB, "mob"},
    snake= {Types.Entities.SNAKE, "mob"},
    bat= {Types.Entities.BAT, "mob"},
    wizard= {Types.Entities.WIZARD, "mob"},
    eye= {Types.Entities.EYE, "mob"},
    skeleton2= {Types.Entities.SKELETON2, "mob"},
    boss= {Types.Entities.BOSS, "mob"},

    sword1= {Types.Entities.SWORD1, "weapon"},
    sword2= {Types.Entities.SWORD2, "weapon"},
    axe= {Types.Entities.AXE, "weapon"},
    redsword= {Types.Entities.REDSWORD, "weapon"},
    bluesword= {Types.Entities.BLUESWORD, "weapon"},
    goldensword= {Types.Entities.GOLDENSWORD, "weapon"},
    morningstar= {Types.Entities.MORNINGSTAR, "weapon"},
    
    firefox= {Types.Entities.FIREFOX, "armor"},
    clotharmor= {Types.Entities.CLOTHARMOR, "armor"},
    leatherarmor= {Types.Entities.LEATHERARMOR, "armor"},
    mailarmor= {Types.Entities.MAILARMOR, "armor"},
    platearmor= {Types.Entities.PLATEARMOR, "armor"},
    redarmor= {Types.Entities.REDARMOR, "armor"},
    goldenarmor= {Types.Entities.GOLDENARMOR, "armor"},

    flask= {Types.Entities.FLASK, "object"},
    cake= {Types.Entities.CAKE, "object"},
    burger= {Types.Entities.BURGER, "object"},
    chest= {Types.Entities.CHEST, "object"},
    firepotion= {Types.Entities.FIREPOTION, "object"},

    guard= {Types.Entities.GUARD, "npc"},
    villagegirl= {Types.Entities.VILLAGEGIRL, "npc"},
    villager= {Types.Entities.VILLAGER, "npc"},
    coder= {Types.Entities.CODER, "npc"},
    scientist= {Types.Entities.SCIENTIST, "npc"},
    priest= {Types.Entities.PRIEST, "npc"},
    king= {Types.Entities.KING, "npc"},
    rick= {Types.Entities.RICK, "npc"},
    nyan= {Types.Entities.NYAN, "npc"},
    sorcerer= {Types.Entities.SORCERER, "npc"},
    agent= {Types.Entities.AGENT, "npc"},
    octocat= {Types.Entities.OCTOCAT, "npc"},
    beachnpc= {Types.Entities.BEACHNPC, "npc"},
    forestnpc= {Types.Entities.FORESTNPC, "npc"},
    desertnpc= {Types.Entities.DESERTNPC, "npc"},
    lavanpc= {Types.Entities.LAVANPC, "npc"},
}

kinds.getType= function(kind)
    return kinds[Types.getKindAsString(kind)][2]
end

Types.rankedWeapons = {
    Types.Entities.SWORD1,
    Types.Entities.SWORD2,
    Types.Entities.AXE,
    Types.Entities.MORNINGSTAR,
    Types.Entities.BLUESWORD,
    Types.Entities.REDSWORD,
    Types.Entities.GOLDENSWORD
}

Types.rankedArmors = {
    Types.Entities.CLOTHARMOR,
    Types.Entities.LEATHERARMOR,
    Types.Entities.MAILARMOR,
    Types.Entities.PLATEARMOR,
    Types.Entities.REDARMOR,
    Types.Entities.GOLDENARMOR
}

Types.getWeaponRank = function(weaponKind)
    return table.find(Types.rankedWeapons, weaponKind)
end

Types.getArmorRank = function(armorKind)
    return table.find(Types.rankedArmors, armorKind)
end

Types.isPlayer = function(kind)
    return kinds.getType(kind) == "player"
end

Types.isMob = function(kind)
    return kinds.getType(kind) == "mob"
end

Types.isNpc = function(kind)
    return kinds.getType(kind) == "npc"
end

Types.isCharacter = function(kind)
    return Types.isMob(kind) or Types.isNpc(kind) or Types.isPlayer(kind)
end

Types.isArmor = function(kind)
    return kinds.getType(kind) == "armor"
end

Types.isWeapon = function(kind)
    return kinds.getType(kind) == "weapon"
end

Types.isObject = function(kind)
    return kinds.getType(kind) == "object"
end

Types.isChest = function(kind)
    return kind == Types.Entities.CHEST
end

Types.isItem = function(kind)
    return Types.isWeapon(kind) 
        or Types.isArmor(kind) 
        or (Types.isObject(kind) and not Types.isChest(kind))
    end

Types.isHealingItem = function(kind)
    return kind == Types.Entities.FLASK 
        or kind == Types.Entities.BURGER
    end

Types.isExpendableItem = function(kind)
    return Types.isHealingItem(kind)
        or kind == Types.Entities.FIREPOTION
        or kind == Types.Entities.CAKE
    end

Types.getKindFromString = function(kind)
    local v = kinds[kind]
    if v then
        return v[1]
    end
end

Types.getKindAsString = function(kind)
    for k,v in pairs(kinds) do
        if type(v) == "table" and v[1] == kind then
            return k
        end
    end
end

Types.forEachKind = function(callback)
    for k,_ in pairs(kinds) do
        callback(kinds[k][1], k)
    end
end

Types.forEachArmor = function(callback)
    Types.forEachKind(function(kind, kindName)
        if Types.isArmor(kind) then
            callback(kind, kindName)
        end
    end)
end

Types.forEachMobOrNpcKind = function(callback)
    Types.forEachKind(function(kind, kindName)
        if Types.isMob(kind) or Types.isNpc(kind) then
            callback(kind, kindName)
        end
    end)
end

Types.forEachArmorKind = function(callback)
    Types.forEachKind(function(kind, kindName)
        if Types.isArmor(kind) then
            callback(kind, kindName)
        end
    end)
end

Types.getOrientationAsString = function(orientation)
        if orientation == Types.Orientations.LEFT then return "left" end
        if orientation == Types.Orientations.RIGHT then return "right" end
        if orientation == Types.Orientations.UP then return"up" end
        if orientation == Types.Orientations.DOWN then return "down" end
end

Types.getRandomItemKind = function(item)
    local all = union(Types.rankedWeapons, Types.rankedArmors)

    local forbidden = {Types.Entities.SWORD1, Types.Entities.CLOTHARMOR}
    local itemKinds = difference(all, forbidden)
    local i = math.random(1,#itemKinds)

    return itemKinds[i]
end

Types.getMessageTypeAsString = function(t)
    local typeName
    each(Types.Messages, function(value, name)
        if value == t then
            typeName = name
        end
    end)
    if not typeName then
        typeName = "UNKNOWN"
    end
    return typeName
end

return Types