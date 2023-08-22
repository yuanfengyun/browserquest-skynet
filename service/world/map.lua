local json = require "dkjson"
local Checkpoint = require "checkpoint"

local function pos(x, y)
    return {x=x, y=y}
end

local function equalPositions(pos1, pos2)
    return pos1.x == pos2.x and pos2.y == pos2.y
end

local M = {}

function M.new(name)
    local o = setmetatable({},{__index=M})
    o:init(name)
    return o
end

function M:init(name)
    self.isLoaded = false
    self.path = name
    self:load()
end

function M:load()
    local f = io.open(self.path,"rb")
    local data = f:read("*a")
    f:close()
    data = json.decode(data)
    self:initMap(data)
end

function M:initMap(data)
    self.width = data.width
    self.height = data.height
    self.collisions = data.collisions
    self.mobAreas = data.roamingAreas
    self.chestAreas = data.chestAreas
    self.staticChests = data.staticChests
    self.staticEntities = data.staticEntities
    self.isLoaded = true
    
    -- zone groups
    self.zoneWidth = 28
    self.zoneHeight = 12
    self.groupWidth = math.floor(self.width / self.zoneWidth)
    self.groupHeight = math.floor(self.height / self.zoneHeight)

    self:initConnectedGroups(data.doors)
    self:initCheckpoints(data.checkpoints)
end

function M:ready(f)
    f()
end

function M:tileIndexToGridPosition(tileNum)
    local x = 0
    local y = 0
    
    local getX = function(num, w)
        if(num == 0) then
            return 0
        end
        return (num % w == 0) and (w - 1) or ((num % w) - 1)
    end

    tileNum = tileNum - 1
    x = getX(tileNum + 1, self.width)
    y = math.floor(tileNum / self.width)

    return { x=x, y=y }
end

function M:GridPositionToTileIndex(x, y)
    return (y * self.width) + x + 1
end

function M:generateCollisionGrid()
    self.grid = {}

    if self.isLoaded then
        local tileIndex = 0
        for i = 1,self.height-1 do
            self.grid[i] = {}
            for j = 1,self.width do
                if(include(self.collisions, tileIndex)) then
                    self.grid[i][j] = 1
                else
                    self.grid[i][j] = 0
                end
                tileIndex = tileIndex + 1
            end
        end
    end
end

function M:isOutOfBounds(x, y)
    return x <= 0 or x >= self.width or y <= 0 or y >= self.height
end

function M:isColliding (x, y)
    if self:isOutOfBounds(x, y) then
        return false
    end
    return self.grid[y][x] == 1
end

function M:GroupIdToGroupPosition(id)
    local posArray = string_split(id,'-')

    return pos(tonumber(posArray[1]), tonumber(posArray[2]))
end

function M:forEachGroup(callback)
    local width = self.groupWidth
    local height = self.groupHeight
    
    for x=0,width-1 do
        for y=0,height-1 do
            callback(tostring(x)..'-'..tostring(y))
        end
    end
end

function M:getGroupIdFromPosition(x, y)
    local w = self.zoneWidth
    local h = self.zoneHeight
    local gx = math.floor((x - 1) / w)
    local gy = math.floor((y - 1) / h)

    return tostring(gx) .. '-' .. tostring(gy)
end

function M:getAdjacentGroupPositions(id)
    local position = self:GroupIdToGroupPosition(id)
    local x = position.x
    local y = position.y
    -- surrounding groups
    local list = {pos(x-1, y-1), pos(x, y-1), pos(x+1, y-1),
                pos(x-1, y),   pos(x, y),   pos(x+1, y),
                pos(x-1, y+1), pos(x, y+1), pos(x+1, y+1)}
    
    -- groups connected via doors
    for _,position1 in pairs(self.connectedGroups[id] or {}) do
        -- don't add a connected group if it's already part of the surrounding ones.
        local equal = false
        for _,groupPos in ipairs(list) do
            if equalPositions(groupPos, position1) then
                equal = true
                break
            end
        end
        if not equal then
            table.insert(list,position1)
        end
    end
    
    local ret = {}
    for _,p in ipairs(list) do
        if p.x < 0 or p.y < 0 or p.x >= self.groupWidth or p.y >= self.groupHeight then

        else
            table.insert(ret,p)
        end
    end

    return ret
end

function M:forEachAdjacentGroup(groupId, callback)
    if groupId then
        for _,v in pairs(self:getAdjacentGroupPositions(groupId)) do
            callback(tostring(v.x)..'-'..tostring(v.y))
        end
    end
end

function M:initConnectedGroups(doors)
    self.connectedGroups = {}
    for _,door in pairs(doors) do
        local groupId = self:getGroupIdFromPosition(door.x, door.y)
        local connectedGroupId = self:getGroupIdFromPosition(door.tx, door.ty)
        local connectedPosition = self:GroupIdToGroupPosition(connectedGroupId)
        
        if self.connectedGroups[groupId] then
            table.insert(self.connectedGroups[groupId],connectedPosition)
        else
            self.connectedGroups[groupId] = {connectedPosition}
        end
    end
end

function M:initCheckpoints(cpList)
    self.checkpoints = {}
    self.startingAreas = {}
    
    for _,cp in pairs(cpList) do
        local checkpoint = Checkpoint.new(cp.id, cp.x, cp.y, cp.w, cp.h)
        self.checkpoints[checkpoint.id] = checkpoint 
        if cp.s == 1 then
            table.insert(self.startingAreas,checkpoint)
        end
    end
end

function M:getCheckpoint(id)
    return self.checkpoints[id]
end

function M:getRandomStartingPosition()
    local nbAreas = #(self.startingAreas)
    local i = math.random(1, nbAreas)
    local area = self.startingAreas[i]
    
    return area:getRandomPosition()
end



return M