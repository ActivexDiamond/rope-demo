	
------------------------------ Env Setup ------------------------------
io.stdout:setvbuf('no')
print(love.getVersion())

------------------------------ Requires ------------------------------
local Vector = require "libs.Vector"

local Rope = require "Rope"
local Player = require "Player"

local bump = require "libs.bump"

------------------------------ Helpers ------------------------------
local BLANK_ROPE = {
	update = function() end,
	draw = function () end,
	points = {},
	movePoint = function() end,
	addPoint = function() end,

}
------------------------------ Upvalues ------------------------------
local createPoint, spawnPlayers
local lastTime = love.timer.getTime()

------------------------------ State ------------------------------
local actionFailedSfx, font;

--local PLAYER1, PLAYER2

local showHelp = true
local SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getMode()

local entities = {}
local rope = BLANK_ROPE

------------------------------ Config ------------------------------
GLOBAL = {
	VERSION = "0.3.0-dev",

	--Physics
	WORLD = bump.newWorld(),
	
	--Player
	PLAYER_SIZE = 32,
	PLAYER_SPEED = 5,
	MAX_TAUTNESS = 1,
	
	KEYBINDS_P1 = {
		up = 'w',
		down = 's',
		left = 'a',
		right = 'd',
	},
	KEYBINDS_P2 = {
		up = 'up',
		down = 'down',
		left = 'left',
		right = 'right',
	},

	--Blocks
	BLOCK_SIZE = 32,
	BLOCK_COLOR = {0.3, 1, 0.3},
	
	--Visuals
	BACKGROUND_COLOR = {0.3, 0.3, 0.6},
		
	--Screen Constants
	SCREEN_WIDTH = SCREEN_WIDTH, 
	SCREEN_HEIGHT = SCREEN_HEIGHT,
	
}

------------------------------ Examples ------------------------------
local function setExample1()
	local x, y = 200, 200
	local xoff = 1.2
	local yoff = 5
	rope = Rope()
	createPoint(x, y, true)
	for i = 1, 100 do
		createPoint(x + i^ xoff, y + i * yoff, false, true)
	end
	createPoint(x + 101^ xoff, y + 101 * yoff, true, true)
--	spawnPlayers()
	print("Points: ", #rope.points)
end

local function setExample2()
	local a = 7
	local b = 50
	local c = 80
	
	rope = Rope(nil, nil, {LENGTH = a, STICK_ADJUST_ITERATIONS = c})
	
	local x, y = SCREEN_WIDTH / 2, 200
	local yoff = rope.LENGTH
	for i = 1, b do
		createPoint(x, y + i * yoff, nil, true)
	end
	spawnPlayers()
	print("Points: ", #rope.points)
end

function spawnPlayers()
	if PLAYER1 or PLAYER2 then
		GLOBAL.WORLD:remove(PLAYER1)
		GLOBAL.WORLD:remove(PLAYER2)
		
		PLAYER1 = nil
		PLAYER2 = nil
	else
		local pos1 = Vector(100, GLOBAL.SCREEN_HEIGHT / 2)
		PLAYER1 = Player(rope, pos1, GLOBAL.KEYBINDS_P1)
		
		local pos2 = Vector(GLOBAL.SCREEN_WIDTH - 100, GLOBAL.SCREEN_HEIGHT / 2)
		PLAYER2 = Player(rope, pos2, GLOBAL.KEYBINDS_P2)
	end
end

local function reset()
	if PLAYER1 then
		GLOBAL.WORLD:remove(PLAYER1)
		PLAYER1 = nil
	end
	if PLAYER2 then
		GLOBAL.WORLD:remove(PLAYER2)
		PLAYER2 = nil
	end
	rope = BLANK_ROPE
	GLOBAL.WORLD = bump.newWorld()
end

------------------------------ Init ------------------------------
function love.load()
	actionFailedSfx = love.audio.newSource("assets/sfx/action_failed.wav", 'static')
	font = love.graphics.newFont("assets/fonts/roboto_mono/RobotoMono-Regular.ttf")
	love.graphics.setFont(font)
	rope = Rope()
end

------------------------------ Core API ------------------------------
function love.update(dt)
	dt = 1/60

	if love.keyboard.isDown('lctrl') and love.mouse.isDown(1) and love.timer.getTime() - lastTime > 0.1 then
		local mx, my = love.mouse.getPosition()
		createPoint(mx, my, nil, true)
	end
	
	if love.keyboard.isDown('f') and lastPoint and mouseCanMove then
		rope:move(#rope.points, Vector(love.mouse.getPosition()))
	end

	if love.keyboard.isDown('space') then
		rope:update(dt)
		if PLAYER1 then PLAYER1:update(dt) end
		if PLAYER2 then PLAYER2:update(dt) end
	end
end

function love.draw()
	local g2d = love.graphics
	g2d.setBackgroundColor(GLOBAL.BACKGROUND_COLOR)
	
	g2d.push('all')
	g2d.setColor(GLOBAL.BLOCK_COLOR)
	for _, obj in ipairs(GLOBAL.WORLD:getItems()) do
		if obj == PLAYER1 or obj == PLAYER2 then
			obj:draw(g2d)
		else
			g2d.rectangle('fill', obj.pos.x, obj.pos.y, obj.size, obj.size)
			local halfSize = obj.size * 0.5
			local colCenter = Vector(obj.pos.x + halfSize, obj.pos.y + halfSize)
			g2d.push('all')
			g2d.setColor(1, 0, 0)
			g2d.rectangle('fill', colCenter.x, colCenter.y, halfSize, halfSize)
			g2d.pop()
				
		end
	end
	g2d.pop()
	
	-- Draw rope.
	rope:draw(g2d)
	
	-- HUD
	if showHelp then
		local x = 0
		local y = SCREEN_HEIGHT - 280
		local lineHeight = 20
		local lineOffset = 0
		g2d.print("===== Controls ===== ", x, y)
		lineOffset = lineOffset + lineHeight	
		g2d.print("LMB         -> Place point.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("LMB + Shift -> Place locked point.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("LMB + Ctrl  -> Place multiple points.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("(You can use Shift+Ctrl simultaneously.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("R           -> Clear world.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("Space       -> Simulate.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("H           -> Toggle help.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("1-9         -> Set example.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("C           -> Toggle draw point.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("P           -> Toggle spawn players.", x, y + lineOffset)						
		lineOffset = lineOffset + lineHeight
		g2d.print("WASD        -> Move player 1 (red).", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("Arrow Keys  -> Move player 2 (yellow).", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("F [Hold]    -> Make last point follow mouse.", x, y + lineOffset)
	end
	g2d.print("rope-demo", 0, 0)
	g2d.print(GLOBAL.VERSION, 0, 20)
	g2d.print("Points: " .. #rope.points, 0, 60)
	g2d.print("FPS: " .. love.timer.getFPS(), 0, 80)
	
	if love.keyboard.isDown('space') then
		g2d.setColor(0, 1, 0)
		g2d.print("Simulating...", 0, 100)
		g2d.setColor(1, 1, 1)
	end
end

function love.keypressed(key, code, rpt)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'r' then
		reset()
		rope = Rope()
	elseif key == 'h' then
		showHelp = not showHelp
	elseif key == 'c' then
		GLOBAL.DRAW_POINTS = not GLOBAL.DRAW_POINTS
	elseif key == 'p' then
		spawnPlayers()
	elseif key == '1' then
		reset()
		setExample1()
	elseif key == '2' then
		reset()
		setExample2()
	end
end

function love.wheelmoved(x,y)
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		createPoint(x, y)
	elseif button == 2 then
		local ent = {pos = Vector(x, y), size = GLOBAL.BLOCK_SIZE}
		GLOBAL.WORLD:add(ent, ent.pos.x, ent.pos.y, ent.size, ent.size)
	end
end

function createPoint(x, y, locked, silent)
	if locked == nil then
		locked = love.keyboard.isDown('lshift')
	end
	local succ = rope:addPoint(Vector(x,y), locked)

	if not succ then
		print("Failed to place point.")
		if not silent then actionFailedSfx:play() end
		return
	end
	
	firstPoint = rope.points[1]
	lastPoint = rope.points[#rope.points]
end