local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector" 

------------------------------ Helpers ------------------------------
--Since comparing floating values isn't the best thing.
local FLOAT_VALUE_OFFSET = 0.000001

------------------------------ Constructor ------------------------------
local Stick = middleclass("Stick")
function Stick:initialize(world, p1, p2, length)
	self.world = world
	self.p1 = p1
	self.p2 = p2
	self.length = length or math.abs((p1.pos - p2.pos).length)

	self.p1:addStick(self)
	self.p2:addStick(self)

	self.lastPos = {p1Pos = p1.pos.copy, p2Pos = p2.pos.copy}
end

------------------------------ Core API ------------------------------
function Stick:update(dt, finalRun)
	local center = (self.p1.pos + self.p2.pos) / 2
	local dir = (self.p1.pos - self.p2.pos).normalized
 
	if not self.p1.locked then
		self.p1:move(center + dir * self.length / 2)
	end
	if not self.p2.locked then
		self.p2:move(center - dir * self.length / 2)
	end
	
---[[
	local currentDist = (self.p1.pos - self.p2.pos).length
--	if currentDist > self.length + GLOBAL.TAUTNESS + FLOAT_VALUE_OFFSET then
--		print "stretch"
--		local dPos = (currentDist - self.length) / 2
--		if not self.p1.locked then
--			self.p1:move(center + dir * dPos)
--			self.p1.lastPos = center + dir * dPos
--		end
--		if not self.p2.locked then
--			self.p2:move(center - dir * dPos)
--			self.p2.lastpos = center - dir * dPos
--		end	
--		self.world:removeStick(self)
--		self.p1.pos = self.lastPos.p1Pos
--		self.p2.pos = self.lastPos.p2Pos
--	end
--	self.lastPos.p1Pos = self.p1.pos.copy
--	self.lastPos.p2Pos = self.p2.pos.copy
--]]
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