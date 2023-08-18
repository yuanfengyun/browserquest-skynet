
local M = {}

function M.dmg(weaponLevel, armorLevel)
    local dealt = weaponLevel * math.random(5, 10)
    local absorbed = armorLevel * math.random(1, 3)
    local dmg =  dealt - absorbed
    
    if dmg <= 0 then
        return math.random(0, 3)
    end
    return dmg
end

function M.hp(armorLevel)
    local hp = 80 + ((armorLevel - 1) * 30)
    return hp
end

return M