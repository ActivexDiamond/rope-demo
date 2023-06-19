local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------
local FLOAT_VALUE_OFFSET = 0.000001

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
		local pos = self.pos.copy
		self:move(self.pos + (pos - self.lastPos))
		self.lastPos = pos.copy
		
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
	local diff = FLOAT_VALUE_OFFSET + GLOBAL.TAUTNESS
	local oldPos = self.pos.copy
	self.pos = to
	
	if self.stick1 then
		local s1Length = (self.stick1.p1.pos - self.stick1.p2.pos).length
		if s1Length > self.stick1.length + diff then 
			self.pos = oldPos
			return
		end
	end

	if self.stick2 then	
		local s2Length = (self.stick2.p1.pos - self.stick2.p2.pos).length
		if s2Length > self.stick2.length + diff then 
			self.pos = oldPos
			return
		end
	end
	
	self.world:move(self, to)
end

------------------------------ Getters / Setters ------------------------------
function Point:addStick(stick)
	if self.stick1 and self.stick2 then
		error "Adding too many sticks to point."
	end
	
	if not self.stick2 then
		self.stick2 = stick
		return
	end
	self.stick1 = stick
	return
end

return Point
