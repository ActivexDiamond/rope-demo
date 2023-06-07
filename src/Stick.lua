local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Stick = middleclass("Stick")
function Stick:initialize(p1, p2, length)
	self.p1 = p1
	self.p2 = p2
	self.length = length or math.abs((p1.pos - p2.pos).length)
end

------------------------------ Core API ------------------------------
function Stick:update(dt)
	local center = (self.p1.pos + self.p2.pos) / 2
	local dir = (self.p1.pos - self.p2.pos).normalized
	if not self.p1.locked then
		self.p1.pos = center + dir * self.length / 2
	end
	if not self.p2.locked then
		self.p2.pos = center - dir * self.length / 2
	end
end

function Stick:draw(g2d)
	g2d.line(self.p1.pos.x, self.p1.pos.y, self.p2.pos.x, self.p2.pos.y)
end

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------
function Stick:isLocked() 
	return self.lock 
end

return Stick