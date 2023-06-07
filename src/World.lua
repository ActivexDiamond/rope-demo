local middleclass = require "libs.middleclass"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local World = middleclass("World")
function World:initialize()
	self.points = {}
	self.sticks = {}
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

------------------------------ API ------------------------------
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