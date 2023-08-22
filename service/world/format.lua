
local Types = require("share")

local M = {}

function M.new()
    local o = {}
    setmetatable(o,M)
    return o
end

function M:init()
    self.formats = {}
    self.formats[Types.Messages.HELLO] = {'s', 'n', 'n'}
    self.formats[Types.Messages.MOVE] = {'n', 'n'}
    self.formats[Types.Messages.LOOTMOVE] = {'n', 'n', 'n'}
    self.formats[Types.Messages.AGGRO] = {'n'}
    self.formats[Types.Messages.ATTACK] = {'n'}
    self.formats[Types.Messages.HIT] = {'n'}
    self.formats[Types.Messages.HURT] = {'n'}
    self.formats[Types.Messages.CHAT] = {'s'}
    self.formats[Types.Messages.LOOT] = {'n'}
    self.formats[Types.Messages.TELEPORT] = {'n', 'n'}
    self.formats[Types.Messages.ZONE] = {}
    self.formats[Types.Messages.OPEN] = {'n'}
    self.formats[Types.Messages.CHECK] = {'n'}
end
        
function M:check(msg)
    local message = msg.slice(0)
    local type = message[0]
    local format = self.formats[type]
    
    message.shift();
    
    if format then    
        if message.length ~= format.length then
            return false
        end
        local n = message.length
        for i = 1,n do
            if(format[i] == 'n' and not isNumber(message[i])) then
                return false
            end
            if(format[i] == 's' and not isString(message[i])) then
                return false
            end
        end
        return true
    elseif(type == Types.Messages.WHO) then
        -- WHO messages have a variable amount of params, all of which must be numbers.
        return message.length > 0 and all(message, function(param)  return isNumber(param) end)
    else
        --log.error("Unknown message type: "+type);
        return false
    end
end

return M