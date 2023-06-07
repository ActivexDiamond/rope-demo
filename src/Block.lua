local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Block = middleclass("Block")
function Block:initialize(world, x, y)
	self.world = world
	self.pos = Vector(x, y)
end

------------------------------ Core API ------------------------------
function Block:draw(g2d)
	g2d.rectangle('fill', self.pos.x, self.pos.y, GLOBAL.BLOCK_SIZE, GLOBAL.BLOCK_SIZE)
end

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return Block