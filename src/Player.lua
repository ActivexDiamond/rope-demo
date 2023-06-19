local middleclass = require "libs.middleclass"
local Vector = require "libs.Vector"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Player = middleclass("Player")
function Player:initialize(rope, pos, keybinds)
	self.rope = rope
	self.pos = pos
	self.w = GLOBAL.PLAYER_SIZE
	self.h = GLOBAL.PLAYER_SIZE
	
	self.vel = Vector(0, 0)
	self.keybinds = keybinds
	self.speed = GLOBAL.PLAYER_SPEED
	
	if self.keybinds == GLOBAL.KEYBINDS_P1 then
		self.targetPoint = #self.rope.points
	else
		self.targetPoint = 1
	end
	self.CENTER_OFFSET_VECTOR = Vector(self.w / 2, self.h / 2)
end

------------------------------ Core API ------------------------------
function Player:update(dt)
	local isDown = love.keyboard.isDown

	--If both are spawned, target second player.
	local other
	if PLAYER1 and PLAYER2 then
		other = self == PLAYER1 and PLAYER2 or PLAYER1
	else
		error "Only one player not currently supported."
	end
	
	local xDir, yDir = 0, 0
	if isDown(self.keybinds.left) then xDir = xDir - 1 end
	if isDown(self.keybinds.right) then xDir = xDir + 1 end
	if isDown(self.keybinds.up) then yDir = yDir - 1 end
	if isDown(self.keybinds.down) then yDir = yDir + 1 end
	self.vel = self.vel + Vector(xDir * self.speed, yDir * self.speed)

	--Check vel direction relative to other player's position.
	--	`other.pos - self.pos` basically translate's `other.pos` to be relative to `self.pos`
	--		instead of being relative to the center of the plane. 
	--	Rearrange cross-product formula to solve for theta instead.
	local a, b =  self.vel, other.pos - self.pos
	local towardsOther = math.acos(a:dot(b) / (a.length * b.length))
	towardsOther = math.deg(towardsOther)
	print(towardsOther, '\t|', self.rope:getTautness())
	
	--If rope is loose enough to allow movement OR moving towards other player; move freely.
	if self.rope:getTautness() < GLOBAL.MAX_TAUTNESS or
			towardsOther < 90 then
		self.rope:movePoint(self.targetPoint, self.pos + self.vel)
		self.pos = self.pos + self.vel
	else --Else, just maintain point at current pos to keep rope from weird jittering.
		self.rope:movePoint(self.targetPoint, self.pos + self.CENTER_OFFSET_VECTOR)
	end
	self.vel = Vector(0, 0)
end

function Player:draw(g2d)
	g2d.push('all')
	if self == PLAYER2 then
		g2d.setColor(1, 1, 0)
	else
		g2d.setColor(1, 0, 0)
	end
	g2d.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
--	g2d.setColor(self.rope.STICK_COLOR)
--	local p1 = self.rope.points[self.targetPoint]
--	local p2 = self.pos + self.CENTER_OFFSET_VECTOR
--	g2d.line(p1.x, p1.y, p2.x, p2.y)		
	
	g2d.pop()
end

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return Player