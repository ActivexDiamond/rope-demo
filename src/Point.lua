local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Point = middleclass("Point")
function Point:initialize(world, x, y, locked)
	self.world = world
	self.pos = Vector(x, y)
	self.lastPos = Vector(x, y)
	self.locked = locked
end

------------------------------ Core API ------------------------------
function Point:update(dt)
	if not self.locked then
		local pos = self.pos
		self:move(self.pos + (pos - self.lastPos))
		self.lastPos = pos
		
		self:move(self.pos + GLOBAL.GRAVITY_VECTOR * dt)
		
	end
end

function Point:draw(g2d)
	if self.locked then
		g2d.push('all')
		g2d.setColor(GLOBAL.LOCKED_POINT_COLOR)
		g2d.rectangle('fill', self.pos.x, self.pos.y, GLOBAL.POINT_SIZE, GLOBAL.POINT_SIZE)
		g2d.pop()
	else
		g2d.rectangle('fill', self.pos.x, self.pos.y, GLOBAL.POINT_SIZE, GLOBAL.POINT_SIZE)
	end
end

------------------------------ API ------------------------------
function Point:move(to)
	self.world:move(self, to)
end

------------------------------ Getters / Setters ------------------------------

return Point