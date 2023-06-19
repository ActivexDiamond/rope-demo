local middleclass = require "libs.middleclass"
local bump = require "libs.bump"
local Vector = require "libs.Vector"
local Block = require "Block"

------------------------------ Helpers ------------------------------
--Since comparing floating values isn't the best thing.
local FLOAT_VALUE_OFFSET = 0.000001

------------------------------ Constructor ------------------------------
local World = middleclass("World")
function World:initialize()
	self.bumpWorld = bump.newWorld()
	self.points = {}
	self.sticks = {}
	self.blocks = {}
	self.entities = {}
end

------------------------------ Core API ------------------------------
function World:update(dt)
	if love.keyboard.isDown('space') and #self.sticks > 0 then

		for _, e in ipairs(self.entities) do 
			e:update(dt)
		end
				
--		local p1, p2 = last.p1.pos.copy, last.p2.pos.copy 
		--Update point positions (motion, gravity, etc...)
		for point in self:iterPoints() do
			point:update(dt)
		end
		
		--Constrain stick lengths.
		for i = 1, GLOBAL.STICK_ADJUST_ITERATIONS do
			for stick in self:iterSticks() do
				stick:update(dt, i == GLOBAL.STICK_ADJUST_ITERATIONS)
			end
		end
		
		local last = self.sticks[1]--#self.sticks]
		local currentDist = (last.p1.pos - last.p2.pos).length
		if currentDist > last.length + GLOBAL.TAUTNESS + FLOAT_VALUE_OFFSET then
			print 'stretch'
--			last.p1.pos, last.p2.pos = p1, p2
		end
		
		mouseCanMove = currentDist < last.length + GLOBAL.TAUTNESS + FLOAT_VALUE_OFFSET
		mouseCanMove = true
	end
end

function World:draw(g2d)
	g2d.setBackgroundColor(GLOBAL.BACKGROUND_COLOR)

	g2d.setColor(GLOBAL.BLOCK_COLOR)
	for _, block in ipairs(self.blocks) do 
		block:draw(g2d)
	end

	for _, e in ipairs(self.entities) do 
		e:draw(g2d)
	end
	
	g2d.setColor(GLOBAL.STICK_COLOR)
	g2d.setLineWidth(GLOBAL.STICK_THICKNESS)
	for stick, p1, p2 in self:iterSticks() do
		stick:draw(g2d)
	end
	
	if self.drawPoints then
		g2d.setColor(GLOBAL.POINT_COLOR)
		for point in self:iterPoints() do
			point:draw(g2d)
		end
	end
	
	g2d.setColor(1, 1, 1)		--reset
end

function World:toggleDrawPoints()
	self.drawPoints = not self.drawPoints
end
------------------------------ Physics API ------------------------------
function World:move(obj, to)
	local x, y, cols = self.bumpWorld:move(obj, to.x, to.y)
	local pos = Vector(x, y)
	obj.pos = pos:clamp(GLOBAL.SCREEN_TOP_LEFT_VECTOR, GLOBAL.SCREEN_BOTTOM_RIGHT_VECTOR)
	
end

------------------------------ API - Objects Addition/Removal ------------------------------
function World:addEntity(e)
	local items = self.bumpWorld:queryRect(e.pos.x, e.pos.y, e.w, e.h)
	if #items == 0 then
		self.bumpWorld:add(e, e.pos.x, e.pos.y, e.w, e.h)
		table.insert(self.entities, e)
		return true
	end
	return false
end

function World:addBlock(x, y)
	local items = self.bumpWorld:queryRect(x, y, GLOBAL.BLOCK_SIZE, GLOBAL.BLOCK_SIZE)
	if #items == 0 then
		local obj = Block(self, x, y)
		self.bumpWorld:add(obj, x, y, GLOBAL.BLOCK_SIZE, GLOBAL.BLOCK_SIZE)
		table.insert(self.blocks, obj)
		return true
	end
	return false
end

function World:addPoint(point)
	local maxDist = math.huge
	for p in self:iterPoints() do
		local dist = (point.pos - p.pos).length
		maxDist = math.min(maxDist, dist)
	end
	if maxDist <= GLOBAL.POINT_SIZE * 2 then
		return false
	end	
	self.points[#self.points + 1] = point
	self.bumpWorld:add(point, point.pos.x, point.pos.y,
			GLOBAL.POINT_PHY_SIZE, GLOBAL.POINT_PHY_SIZE)
	return true
end

function World:addStick(stick)
	self.sticks[#self.sticks + 1] = stick
	return true
end

function World:clearAllObjects()
	self.points = {}
	self.sticks = {}
	self.blocks = {}
	self.bumpWorld = bump.newWorld()
end

function World:removeEntity(e)
	for k, v in ipairs(self.entities) do
		if v == e then
			table.remove(self.entities, k)
			self.bumpWorld:remove(e)
			return true
		end
	end
	return false
end

function World:removeStick(obj)
	for k, v in ipairs(self.sticks) do
		if v == obj then
			table.remove(self.sticks, k)
			return true
		end
	end
	return false
end

------------------------------ Iters ------------------------------
function World:iterPoints()
	return coroutine.wrap(function()
		for k, point in ipairs(self.points) do
			coroutine.yield(point, point.x, point.y)
		end
	end)
end

function World:iterSticks()
	return coroutine.wrap(function()
		for k, stick in ipairs(self.sticks) do
			coroutine.yield(stick, stick.p1, stick.p2)
		end
	end)

end



------------------------------ Getters / Setters ------------------------------

return World
