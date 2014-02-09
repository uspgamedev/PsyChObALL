require "Base"
require "Body"
require "Timer"
require "VarTimer"
require "Effect"
require "ColorManager"
require "RecordsManager"
require "FileManager"
require "SoundManager"
require "menus.MenuManager"
require "DeathManager"
require "UI"
require "Cheats"
require "Enemies"
require "CircleEffect"
require "Psychoball"
require "Levels"
require "Button"
require "Text"
require "Formations"
require "ImageBody"
require "Enemy"
require "Shot"
require "Warning"

function love.load()
	initBase()
	initGameVars()
	UI.init()

	mouse.setGrab(false)
end

function initBase()
	-- [[Initing Variables]]
	v = 240 --main velocity of everything
	totalRunningTime = 0

	-- state 'constants'
	splashscreen = -1
	recordsmenu  = 0 
	mainmenu = 1
	tutorialmenu = 2
	tutorialmenu2 = 3
	levelselect = 4
	survival = 10
	story = 11

	state = mainmenu
	sqrt2 = math.sqrt(2)
	resetted = false
	godmode = false
	paused = false
	usingjoystick = joystick.isOpen(1)

	paintables = {}
	setmetatable(paintables, {
		__index = function ( self, index )
			for _, p in pairs(self) do
				if p.__type == index then return p end
			end
		end
		})

	for _, bodyType in ipairs {Shot, Enemy, Effect, Enemies, Warning, CircleEffect, Text, ImageBody, Button} do
		bodyType:paintOn(paintables)
	end

	table.sort(paintables, function(a, b) return a.ord < b.ord end) --sort by painting order

	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	FileManager.init()
	FileManager.readConfig()
	FileManager.readStats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage 'resources/LogoBeta.png'
	splash = graphics.newImage 'resources/Marvellous Soft.png'
	splashtimer = Timer:new{timelimit = 1.75, running = true, persistent = true, onceOnly = true, pausable = false, 
		funcToCall = function() end}

	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))
	version = '1.0.1 indev'
	latest = Base.getLatestVersion() or version
	oldVersion = version < latest
	SoundManager.init()
	Cheats.init()
	--[[End of Loading Resources]]

	screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end
end

function initGameVars()
	for _, toBeInited in ipairs {RecordsManager, ColorManager, MenuManager, DeathManager, CircleEffect, Enemy, Enemies, Shot, Psychoball} do
		toBeInited.init()
	end
		
	-- [[Creating Persistent Timers]]

	angle = VarTimer:new {
		var = 0,
		speed = 1,
		pausable = false
	}
	-- [[End of Creating Persistent Timers]]

	psycho = Psychoball:new {
		position = Vector:new{width/2,height/2}
	}
	
	keyspressed = {}
	timefactor = 1.0

	Levels.loadAll()
end

local blastscore, lifescore
function resetVars()
	if Cheats.konamicode then
		psycho.ultraCounter = 30
		if psycho.lives then psycho.lives = 30 end
		Cheats.konamicode = false
	else
		psycho.ultraCounter = 3
	end
	
	Enemy.list:clear()

	for _, toReset in ipairs {psycho, RecordsManager} do
		toReset:reset()
	end

	--[[Resetting Paintables]]
	Shot:clear()
	if notclearcircleeffect then notclearcircleeffect = false
	else CircleEffect:clear() end
	Enemy:clear()
	Enemies:clear()
	Warning:clear()
	Text:clear()
	ImageBody:clear()
	--[[End of Resetting Paintables]]
	Base.clearTable(keyspressed)

	timefactor = 1.0

	DeathManager.gameLost = false
	paused = false

	DeathManager.resetDeathText()
end

function reloadSurvival()
	SoundManager.changeSong(SoundManager.survivalsong)
	ColorManager.currentEffect = nil
	if state == survival then Effect:clear() end
	state = survival
	Enemy.addtimer:funcToCall()
	resetVars()
	Timer.closeOldTimers()

	SoundManager.restart()
	Enemies.restartSurvival()
	Enemy.addtimer:start(1.5)
	Enemy.releasetimer:start(.7)

	mouse.setGrab(true)
end

function reloadStory( name, reloadEverything )
	if name and name ~= 'Tutorial' and name > RecordsManager.records.story.lastLevel then RecordsManager.records.story.lastLevel = name end
	if psycho.pseudoDied then
		psycho.pseudoDied = false
		paintables.deathEffects.bodies = nil
		paintables.deathEffects = nil
	end
	if not psycho.canBeHit then
		psycho.canBeHit = true
		psycho.alpha = 255
	end
	Effect:clear()
	Timer.closeOldTimers()
	if reloadEverything or name == 'Level 1-1' then
		state = story
		psycho.lives = Psychoball.lives
		SoundManager.changeSong(SoundManager.limitlesssong)
		resetVars()
		Timer.closeOldTimers()

		SoundManager.restart()
		Enemies.restartStory()

		mouse.setGrab(true)
	end
	Levels.runLevel(name)
end


function onMenu()
	return state >= 0 and state < 10
end

function onGame()
	return state >= 10 and state < 20
end

function love.draw()
	-- [[Setting camera]]
	graphics.translate(width/2, height/2)
	graphics.rotate(angle.var)
	graphics.translate(-width/2, -height/2)
	graphics.setLineWidth(3)
	graphics.setFont(Base.getFont(12))

	drawBackground()
	
	if splashtimer.running then
		graphics.setColor(255,255,255,255)
		graphics.rectangle("fill", 0, 0, width, height) --background color
		graphics.draw(splash, 100, 80, 0, .55, .55)
		return
	end

	--[[End of setting camera]]
	for _, paintable in pairs(paintables) do
		paintable:drawComponents()
	end

	--[[Drawing Game Objects]]
	if onGame() then
		drawShootingDirection()
		--drawing psychoball
		if not Cheats.invisible then
			psycho:draw()
		end
	end
	--[[End of Drawing Game Objects]]

	UI.draw()
	MenuManager.draw()
	Psychoball.additionalDrawing()
end

function drawBackground()
	if not Psychoball.turnLightsOff then
		local color = ColorManager.getRawColor(-ColorManager.timer.time*.35)
		color[1] = color[1] / 3
		color[2] = color[2] / 3
		color[3] = color[3] / 3
		ColorManager.applyEffect(nil, color)
		color[1] = color[1] / 4
		color[2] = color[2] / 4
		color[3] = color[3] / 4
		graphics.setColor(color)
	else
		graphics.setColor(100, 100, 100)
	end

	graphics.setPixelEffect()
	graphics.draw(Base.pixel, 0, 0, 0, width, height) -- background color
end

function drawShootingDirection()
	if DeathManager.gameLost or psycho.pseudoDied then return end

	graphics.setLineWidth(1)
	local color = ColorManager.getComposedColor(2)
	graphics.setColor(color)
	if usingjoystick then
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local a1, a2 = joystick.getAxis(1, 4), joystick.getAxis(1, 5)
		if a1 == 0 and a2 == 0 then return end
		local x = a2 > 0 and width or 0
		-- Lazyness Warning: drawing a huge line to avoid having to think about the exact calculations!
		graphics.line(psycho.x, psycho.y, a2 * 1200 + psycho.x, a1 * 1200 + psycho.y) 
	else
		if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end
		graphics.circle("line", mouseX, mouseY, 5)
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local x = mouseX > psycho.x and width or 0
		graphics.setPixelEffect()
		graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((mouseY - psycho.y)/(mouseX - psycho.x)))
	end
	if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end
end

function love.update(dt)
	if dt > 0.03333 then dt = 0.03333 end
	totalRunningTime = totalRunningTime + dt
	mouseX, mouseY = mouse.getPosition()
	isPaused = (paused or onMenu())

	Timer.updatetimers(dt, timefactor, isPaused, DeathManager.gameLost)
	
	dt = dt * timefactor
	
	if paused then return end
	if onGame() then
		psycho:update(dt)
	end

	updateBodies(dt)
	MenuManager.update(dt)
end

function updateBodies( dt )
	for i, v in pairs(paintables) do
		if not v.updateComponents then print('error on ' .. i) table.foreach(v, print) error() end
		v:updateComponents(dt)
	end
end

function love.mousepressed(x, y, btn)
	if splashtimer.running then return end
	x, y  = x/ratio, y/ratio
	if btn == 'l' and onGame() and not (DeathManager.gameLost or paused or psycho.pseudoDied) then
		Shot.timer:start(Shot.timer.timelimit) --starts shooting already
	end
	UI.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
	if splashtimer.running then return end
	x, y  = x/ratio, y/ratio		
	UI.mousereleased(x, y, btn)
	if btn == 'l' and onGame() then
		Shot.timer:stop()
	end
end

function love.joystickpressed( joynum, btn )
	if not usingjoystick then return end
	psycho:joystickPressed(joynum, btn)
end

function love.joystickreleased( joynum, btn )
	if not usingjoystick then return end
	psycho:joystickReleased(joynum, btn)
end

function love.keypressed(key)
	if splashtimer.running then return end
	keyspressed[key] = true

	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if not DeathManager.gameLost and onGame() then 
		psycho:keyPressed(key)
	end

	UI.keypressed(key)
	Cheats.keypressed(key)
	SoundManager.keypressed(key)
end

function love.keyreleased(key)
	if not keyspressed[key] then return
	else keyspressed[key] = false end

	if not DeathManager.gameLost and onGame() then
		psycho:keyReleased(key)
	end
	
	if key == 'scrollock' then 
		graphics.newScreenshot():encode('screenshot_' .. screenshotnumber .. '.png')
		screenshotnumber = screenshotnumber + 1
	end
end

function love.focus(f)
	if onGame() and not (f or DeathManager.gameLost) then paused = true end
end

function love.quit()
	FileManager.writeConfig()
	FileManager.writeStats()
end