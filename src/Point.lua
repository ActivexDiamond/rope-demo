local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Point = middleclass("Point")
function Point:initialize(x, y, locked)
	self.pos = Vector(x, y)
	self.lastPos = Vector(x, y)
	self.locked = locked
end

------------------------------ Core API ------------------------------
function Point:update(dt)
	if not self.locked then
		local pos = self.pos
		self.pos = self.pos + (self.pos - self.lastPos)
		self.lastPos = pos
		
		self.pos = self.pos + GLOBAL.GRAVITY_VECTOR * dt
		
		self.pos = self.pos:clamp(GLOBAL.SCREEN_TOP_LEFT_VECTOR, GLOBAL.SCREEN_BOTTOM_RIGHT_VECTOR)
	end
end

function Point:draw(g2d)
	if self.locked then
		g2d.push('all')
		g2d.setColor(GLOBAL.LOCKED_POINT_COLOR)
		g2d.circle('fill', self.pos.x, self.pos.y, GLOBAL.POINT_SIZE)
		g2d.pop()
	else
		g2d.circle('fill', self.pos.x, self.pos.y, GLOBAL.POINT_SIZE)
	end
end

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return Point