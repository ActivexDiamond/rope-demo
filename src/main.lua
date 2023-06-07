------------------------------ Env Setup ------------------------------
io.stdout:setvbuf('no')
print(love.getVersion())

------------------------------ Requires ------------------------------
local Vector = require "libs.Vector"

local World = require "World"
local Point = require "Point"
local Stick = require "Stick"

------------------------------ Config ------------------------------
local SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getMode()
local POINT_SIZE = 5

GLOBAL = {
	VERSION = "dev-1.0",

	POINT_SIZE = POINT_SIZE,
	POINT_COLOR = {1, 1, 1},
	LOCKED_POINT_COLOR = {1, 1, 0},
	STICK_COLOR = {0, 0, 0},
	STICK_THICKNESS = 4,
	BLOCK_COLOR = {0.3, 1, 0.3},
	BACKGROUND_COLOR = {0.3, 0.3, 0.6},
	
	GRAVITY_VECTOR = Vector(0, 10),
	POINT_PHY_SIZE = POINT_SIZE, 
	BLOCK_SIZE = 32,
	
	SCREEN_WIDTH = SCREEN_WIDTH, 
	SCREEN_HEIGHT = SCREEN_HEIGHT,
	SCREEN_TOP_LEFT_VECTOR = Vector(POINT_SIZE, POINT_SIZE),
	SCREEN_BOTTOM_RIGHT_VECTOR = Vector(SCREEN_WIDTH - POINT_SIZE, SCREEN_HEIGHT - POINT_SIZE),
	
	--Lower numbers in crease rope stretchiness. Increases performance significantly.
	STICK_ADJUST_ITERATIONS = 5,
}

------------------------------ Init ------------------------------
local world, actionFailedSfx, bgm;
local lastPoint, createPoint;
local showHelp = true
function love.load()
	world = World()
	
	actionFailedSfx = love.audio.newSource("assets/sfx/action_failed.wav", 'static')
end

------------------------------ Core API ------------------------------
local lastTime = love.timer.getTime()
function love.update(dt)
	world:update(dt)

	if love.keyboard.isDown('lctrl') and love.mouse.isDown(1) and love.timer.getTime() - lastTime > 0.1 then
		local mx, my = love.mouse.getPosition()
		createPoint(mx, my, true)
	end
end

function love.draw()
	local g2d = love.graphics
	
	-- Draw points and lines.
	world:draw(g2d)
	
	-- HUD
	if showHelp then
		local x = 0
		local y = SCREEN_HEIGHT - 160
		local lineHeight = 20
		local lineOffset = 0
		g2d.print("===== Controls ===== ", x, y)
		lineOffset = lineOffset + lineHeight	
		g2d.print("LMB             -> Place point.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("LMB + Shift -> Place locked point.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("LMB + Ctrl  -> Place multiple points.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("(You can use Shift+Ctrl simultaneously.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("R              -> Clear world.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("Space       -> Simulate.", x, y + lineOffset)
		lineOffset = lineOffset + lineHeight
		g2d.print("H              -> Toggle help.", x, y + lineOffset)
	end
	g2d.print("rope-demo", 0, 0)
	g2d.print(GLOBAL.VERSION, 0, 20)
	
	if love.keyboard.isDown('space') then
		g2d.setColor(0, 1, 0)
		g2d.print("Simulating...", 0, 40)
		g2d.setColor(1, 1, 1)
	end
end

function love.keypressed(key, code, rpt)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'r' then
		world:clearAllObjects()
		lastPoint = nil
	elseif key == 'h' then
		showHelp = not showHelp
	end
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		createPoint(x, y)
	elseif button == 2 then
		world:addBlock(x, y)
	end
end

function createPoint(x, y, silent)
	local locked = love.keyboard.isDown('lshift')
	local point = Point(world, x, y, locked)
	local succ = world:addPoint(point)

	if not succ then
		print("Failed to place point.")
		if not silent then actionFailedSfx:play() end
		return
	end
	if not lastPoint then
		lastPoint = point
		return
	end
	
	local stick = Stick(point, lastPoint)
	lastPoint = point
	local succ = world:addStick(stick)
	if not succ then
		print("Failed to place stick.")
	end
end