local middleclass = require "libs.middleclass"
local bump = require "libs.bump"
local Vector = require "libs.Vector"
local Block = require "Block"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local World = middleclass("World")
function World:initialize()
	self.bumpWorld = bump.newWorld()
	self.points = {}
	self.sticks = {}
	self.blocks = {}
end

------------------------------ Core API ------------------------------
function World:update(dt)
	if love.keyboard.isDown('space') then
		for point in self:iterPoints() do
			point:update(dt)
		end
		
		for i = 1, GLOBAL.STICK_ADJUST_ITERATIONS do
			for stick in self:iterSticks() do
				stick:update(dt)
			end
		end
	end
end

function World:draw(g2d)
	g2d.setBackgroundColor(GLOBAL.BACKGROUND_COLOR)

	g2d.setColor(GLOBAL.BLOCK_COLOR)
	for _, block in ipairs(self.blocks) do 
		block:draw(g2d)
	end

	g2d.setColor(GLOBAL.STICK_COLOR)
	g2d.setLineWidth(GLOBAL.STICK_THICKNESS)
	for stick, p1, p2 in self:iterSticks() do
		stick:draw(g2d)
	end
	
	g2d.setColor(GLOBAL.POINT_COLOR)
	for point in self:iterPoints() do
		point:draw(g2d)
	end

	g2d.setColor(1, 1, 1)		--reset
end

------------------------------ Physics API ------------------------------
function World:move(obj, to)
	local x, y, cols = self.bumpWorld:move(obj, to.x, to.y)
	local pos = Vector(x, y)
	obj.pos = pos:clamp(GLOBAL.SCREEN_TOP_LEFT_VECTOR, GLOBAL.SCREEN_BOTTOM_RIGHT_VECTOR)
	
end

------------------------------ API ------------------------------
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
end

function World:iterPoints()
	return coroutine.wrap(function()
		for k, point in pairs(self.points) do
			coroutine.yield(point, point.x, point.y)
		end
	end)
end

function World:iterSticks()
	return coroutine.wrap(function()
		for k, stick in pairs(self.sticks) do
			coroutine.yield(stick, stick.p1, stick.p2)
		end
	end)

end



------------------------------ Getters / Setters ------------------------------

return World