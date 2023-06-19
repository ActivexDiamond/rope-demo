local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector"

------------------------------ Fallbacks ------------------------------
local DEFAULT = {
	--Visuals
	POINT_COLOR = {1, 1, 1},
	LOCKED_POINT_COLOR = {1, 1, 0},
	STICK_COLOR = {0, 0, 0},
	STICK_THICKNESS = 4,

	
	--Physics
	POINT_SIZE = 5,
	GRAVITY_VECTOR = Vector(0, 10),

	--Lower numbers increase rope stretchiness. Increases performance significantly.
	STICK_ADJUST_ITERATIONS = 80,
	
	STRETCH_FACTOR = 8,
	LENGTH = 2
}


------------------------------ Constructor ------------------------------
local Rope = middleclass("Rope")
function Rope:initialize(points, locked, opt)
	opt = opt or {}
	for k, v in pairs(DEFAULT) do
		self[k] = opt[k] or v
	end
	self.SCREEN_TOP_LEFT_VECTOR = Vector(self.POINT_SIZE, self.POINT_SIZE)
	self.SCREEN_BOTTOM_RIGHT_VECTOR = Vector(GLOBAL.SCREEN_WIDTH - self.POINT_SIZE,
			GLOBAL.SCREEN_HEIGHT - self.POINT_SIZE)
			
	self.points = points or {}
	self.lasts = {}
	for k, v in ipairs(self.points) do
		self.lasts[k] = v.copy
	end
	
	self.locked = locked or {}
	
	self.moves = {}
	
	self.currentLength = 0
	self.targetLength = 0
end

------------------------------ Core API ------------------------------
function Rope:update(dt)
	--Update points positions and Verletintegration.	
	for k, p in ipairs(self.points) do
		--Skip locked points.
		if self.locked[k] then goto continue end
		
		--Needed for verlet integration.
		local oldPos = p.copy
		
		--Apply verlet integration.
		p = p + (p - self.lasts[k])
		
		--Apply external requests.
		if self.moves[k] then
			p = self.moves[k]
			self.moves[k] = nil
		end
		--Apply gravity and clamp to window, and update point.
		self.points[k] = (p + self.GRAVITY_VECTOR * dt):
				clamp(self.SCREEN_TOP_LEFT_VECTOR, self.SCREEN_BOTTOM_RIGHT_VECTOR)
		
		--Needed for verlet integration. 
		self.lasts[k] = oldPos
		::continue::
	end
	
	--Apply constraints
	for i = 1, self.STICK_ADJUST_ITERATIONS do
		for i = 1, #self.points - 1 do
			local p1 = self.points[i]
			local p2 = self.points[i + 1]
			
			local diff = p1 - p2
			local dist = diff.length
			local dDist = 0
			if dist > 0 then 
				dDist = (self.LENGTH - dist) / dist
			end
			
			if not self.locked[i] then
				self.points[i] 		= p1 + diff * (0.5 * dDist)
			end
			if not self.locked[i + 1] then
				self.points[i + 1] 	= p2 - diff * (0.5 * dDist)
			end
		end
		if love.keyboard.isDown('f') then
			self.points[#self.points] = Vector(love.mouse.getPosition())
		end

		--[[
		local first = self.points[1]
		local last = self.points[#self.points]
		local dist = (first - last).length
		local ropeLen = self.LENGTH * #self.points
		if dist > 0 and dist > ropeLen then
			local dir = (last - first).normalized
			self.points[#self.points] = first + ropeLen * dir
		end
		--]]
	end
	
	--Calculate current length.
	local len = 0
	for i = 1, #self.points - 1 do
		local p1 = self.points[i]
		local p2 = self.points[i + 1]
		len = len + (p1 - p2).length
	end	
	self.currentLength = len
	self.targetLength = self.LENGTH * #self.points 
--	print(self.currentLength, self.targetLength, self.currentLength - self.targetLength)
end

function Rope:draw(g2d)
	g2d.push('all')
	
	--Draw points.
	if GLOBAL.DRAW_POINTS then
		g2d.setColor(self.POINT_COLOR)
		for k, v in ipairs(self.points) do
			if not self.locked[k] then
				g2d.rectangle('fill', v.x, v.y, self.POINT_SIZE, self.POINT_SIZE)
			else
				g2d.setColor(self.LOCKED_POINT_COLOR)
				g2d.rectangle('fill', v.x, v.y, self.POINT_SIZE, self.POINT_SIZE)
				g2d.setColor(self.POINT_COLOR)	
			end
		end
	end

	--Draw sticks.
	g2d.setColor(self.STICK_COLOR)
	for i = 1, #self.points - 1 do
		local p1 = self.points[i]
		local p2 = self.points[i + 1]
		g2d.line(p1.x, p1.y, p2.x, p2.y)		
	end
	
	g2d.pop()
end

------------------------------ API ------------------------------
function Rope:addPoint(pos, locked)
	local i = #self.points + 1
	self.points[i] =  pos
	self.lasts[i] =  pos
	if locked then self.locked[i] = true end
	return true
end

function Rope:movePoint(index, to)
	if self.moves[index] then
		self.moves[index] = self.moves[index] + (self.moves[index] - to)
	else
		self.moves[index] = to
	end
end

------------------------------ Getters / Setters ------------------------------
function Rope:getTautness()
	return self.currentLength - self.targetLength
end

return Rope