
local Utils = require('utils')
local Types = require("share")
local Class = require "class"

local Checkpoint = Class.extend({
    init= function(self, id, x, y, width, height)
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    end,
    
    getRandomPosition= function(this)
        local pos = {}
        
        pos.x = this.x + Utils.randomInt(0, this.width - 1)
        pos.y = this.y + Utils.randomInt(0, this.height - 1)
        return pos
    end
})

return Checkpoint