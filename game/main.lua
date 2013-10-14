require "Base"
require "Body"
require "Timer"
require "VarTimer"
require "Effect"
require "ColorManager"
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
	totaltime = 0
	splashscreen = -1
	mainmenu = 1 -- mainmenu
	tutorialmenu = 2
	levelselect = 3
	achievmenu  = 0 -- Tela de achievements
	survival = 10 -- modo de jogo survival
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
	Shot:paintOn(paintables)
	Enemy:paintOn(paintables)
	Effect:paintOn(paintables)
	Enemies:paintOn(paintables)
	Warning:paintOn(paintables)
	CircleEffect:paintOn(paintables)
	Text:paintOn(paintables)
	ImageBody:paintOn(paintables)
	Button:paintOn(paintables)
	table.sort(paintables, function(a, b) return a.ord < b.ord end)

	records = {}
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
	for _, toBeInited in ipairs {ColorManager, MenuManager, DeathManager, CircleEffect, Enemy, Enemies, Shot, Psychoball} do
		toBeInited.init()
	end
		
	-- [[Creating Persistent Timers]]
	multtimer = Timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gameLost = false
	}

	function multtimer:funcToCall() -- resets multiplier
		multiplier = 1
		self:stop()
	end

	function multtimer:handleReset()
		self:funcToCall()
	end

	inverttimer = Timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gameLost = false
	}

	function inverttimer:funcToCall() -- disinverts the screen color
		if ColorManager.currentEffect ~= ColorManager.noLSDEffect then 
			SoundManager.setPitch(1)
			timefactor = 1.0
			ColorManager.currentEffect = nil
		end
		self:stop()
	end

	function inverttimer:handleReset()
		self:funcToCall()
	end

	angle = VarTimer:new {
		var = 0,
		speed = 1,
		pausable = false
	}
	-- [[End of Creating Persistent Timers]]

	psycho = Psychoball:new{
		position = Vector:new{width/2,height/2}
	}
	
	auxspeed = Vector:new {}
	keyspressed = {}
	timefactor = 1.0

	Levels.loadAll()
end

function resetVars()
	if Cheats.konamicode then
		ultracounter = 30
		if psycho.lives then psycho.lives = 30 end
		Cheats.konamicode = false
	else
		ultracounter = 3
	end
	
	Enemy.list:clear()
	auxspeed:reset()
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
	multiplier = 1
	gametime = 0
	blastime = 0
	score = 0
	blastscore = 0 --Variavel que dá ultrablast points por pontos
	lifescore = 0

	DeathManager.gameLost = false
	paused = false

	DeathManager.resetDeathText()
end

function reloadSurvival()
	SoundManager.changeSong(SoundManager.survivalsong)
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
	if name and name > records.story.lastLevel then records.story.lastLevel = name end
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

function getStateClass(st)
	st = st or state
	if st < 10 then return 1
	elseif st >= 10 and st < 20 then return 2
	elseif st == levelselect then return 3 end
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
end

function drawBackground()
	local color = ColorManager.getRawColor(-ColorManager.timer.time*.35)
	color[1] = color[1] / 3
	color[2] = color[2] / 3
	color[3] = color[3] / 3
	ColorManager.applyEffect(nil, color)
	color[1] = color[1] / 4
	color[2] = color[2] / 4
	color[3] = color[3] / 4
	graphics.setColor(color)

	graphics.rectangle("fill", 0, 0, width, height) --background color
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
		graphics.line(psycho.x, psycho.y, a2*1200 + psycho.x, a1*1200 + psycho.y)
	else
		graphics.setPixelEffect(Base.circleShader)
		graphics.circle("line", mouseX, mouseY, 5)
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local x = mouseX > psycho.x and width or 0
		graphics.setPixelEffect()
		graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((mouseY - psycho.y)/(mouseX - psycho.x)))
	end
	graphics.setPixelEffect(Base.circleShader)
end

function love.update(dt)
	if dt > 0.03333 then dt = 0.03333 end
	totaltime = totaltime + dt
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
	x, y  = x/ratio, y/ratio
	if btn == 'l' and onGame() and not (DeathManager.gameLost or paused or psycho.pseudoDied) then
		Shot.timer:start(Shot.timer.timelimit) --starts shooting already
	end
	UI.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
	x, y  = x/ratio, y/ratio		
	UI.mousereleased(x, y, btn)
	if btn == 'l' and onGame() then
		Shot.timer:stop()
	end
end

function addscore(x)
	if not DeathManager.gameLost then
		score = score + x
		blastscore = blastscore + x
		lifescore = lifescore + x
		if blastscore >= (state == survival and 7000 or 2000) then
			blastscore = blastscore - (state == survival and 7000 or 2000)
			ultracounter = ultracounter + 1
		end
		if state == story and lifescore >= 15000 then
			lifescore = lifescore - 15000
			psycho:addLife()
		end
	end
end

function love.joystickpressed( joynum, btn )
	if not usingjoystick then return end
	psycho:joystickpressed(joynum, btn)
end

function love.joystickreleased( joynum, btn )
	if not usingjoystick then return end
	psycho:joystickreleased(joynum, btn)
end

function love.keypressed(key)
	keyspressed[key] = true

	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if not DeathManager.gameLost and onGame() then 
		psycho:keypressed(key)
	end

	UI.keypressed(key)
	Cheats.keypressed(key)
	SoundManager.keypressed(key)
end

function love.keyreleased(key)
	if not keyspressed[key] then return
	else keyspressed[key] = false end

	if not DeathManager.gameLost and onGame() then
		psycho:keyreleased(key)
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