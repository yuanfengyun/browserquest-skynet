
local Utils = {}
local Types = require("share");
local sanitizer = require('sanitizer')

Utils.sanitize = function(string)
-- Strip unsafe tags, then escape as html entities.
    return sanitizer.escape(sanitizer.sanitize(string))
end

Utils.random = function(range)
    return math.random(range)
end

Utils.randomRange = function(min, max)
    return min + (math.random() * (max - min))
end

Utils.randomInt = function(min, max)
    return math.random(min,max)
end

Utils.clamp = function(min, max, value)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

Utils.randomOrientation = function()
    local o, r = Utils.random(4)
    
    if(r == 0) then
        o = Types.Orientations.LEFT
    elseif(r == 1) then
        o = Types.Orientations.RIGHT
    elseif(r == 2) then
        o = Types.Orientations.UP
    elseif(r == 3) then
        o = Types.Orientations.DOWN
    end
    return o;
end

Utils.distanceTo = function(x, y, x2, y2)
    local distX = math.abs(x - x2);
    local distY = math.abs(y - y2);

    return (distX > distY) and distX or distY
end

return Utils