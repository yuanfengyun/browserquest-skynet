function table.find(t,value)
    for k,v in pairs(t) do
        if v == value then
            return k
        end
    end
end

function union(a,b)
    local ret = {}
    for _,v in ipairs(a) do
        table.insert(ret,v)
    end

    for _,v in ipairs(b) do
        table.insert(ret,v)
    end
end

function difference(a,b)
    local ret = {}
    for _,v in ipairs(a) do
        if not table.find(b,v) then
            table.insert(ret,v)
        end
    end
    return ret
end

function each(a,f)
    for k,v in pairs(a) do
        f(v,k)
    end
end

function distanceTo(x,y,x1,y1)
    local xx = (x-x1)*(x-x1)
    local yy = (y-y1)*(y-y1)
    return math.sqrt(xx+yy)
end

function all(t,f)
    for _,v in pairs(t) do
        if not f(v) then
            return false
        end
    end
    return true
end

function isNumber(a)
    return type(a) == "number"
end

function isString(a)
    return type(a) == "string"
end

function inin(a,b)
    for _,v in pairs(b) do
        if v == b then
            return true
        end
    end
end

function keys(a)
    local r = {}
    for _,v in pairs(a) do
        table.insert(r,k)
    end
    return r
end

function map(a,f)

end

function reject(a,f)
    local r = {}
    for k,v in ipairs(a) do
        if not f(v) then
            table.insert(r,v)
        end
    end
    return r
end


function string_split(str, sep)
    local result = {}
    if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
    end
 
    if string.len(sep) == 0 then
        return result
    end
    local pattern = string.format("([^%s]+)", sep)
 
    string.gsub(
        str,
        pattern,
        function(c)
            result[#result + 1] = c
        end
    )
 
    return result
end

function include(a,b)
    for k,v in pairs(a) do
        if k == b then
            return true
        end
    end
    return 
end