require "base"
require "timer"
require "ColorManager"
require "body"
require "formations"
require "levels"
require "userinterface"
require "text"
require "imagebody"
require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "vartimer"
require "enemies"
require "psychoball"
require "warning"
require "button"
require "filemanager"
require "soundmanager"
require "cheats"

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
	achievmenu  = 0 -- Tela de achievements
	survival = 10 -- modo de jogo survival
	story = 11
	levelselect = 20
	state = mainmenu
	sqrt2 = math.sqrt(2)
	fonts = {}
	coolfonts = {}
	resetted = false
	godmode = false
	usingjoystick = joystick.isOpen(1)

	gamelostinfo =  {
		timetorestart = .5,
		timeofdeath = nil,
		isrestarting = false
	}

	paintables = {}
	setmetatable(paintables, {
		__index = function ( self, index )
			for _, p in pairs(self) do
				if p.name == index then return p end
			end
		end
		})
	Shot:paintOn(paintables)
	Enemy:paintOn(paintables)
	Effect:paintOn(paintables)
	enemies:paintOn(paintables)
	Warning:paintOn(paintables)
	CircleEffect:paintOn(paintables)
	Text:paintOn(paintables)
	ImageBody:paintOn(paintables)
	Button:paintOn(paintables)
	table.sort(paintables, function(a, b) return a.ord < b.ord end)

	UI.self.paintables = {} --[[If you just use UI.paintables = {} it actually
		sets _G.paintables because of base.globalize]]

	bestscore, besttime, bestmult = 0, 0, 0
	lastLevel = 'Level 1-1'
	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	FileManager.init()
	FileManager.readConfig()
	FileManager.readStats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage 'resources/LogoBeta.png'
	splash = graphics.newImage 'resources/Marvellous Soft.png'
	splashtimer = Timer:new{timelimit = 1.75, running = true, persistent = true, onceonly = true, pausable = false, 
		funcToCall = function() end}

	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))
	version = '1.0.1 indev'
	latest = base.getLatestVersion() or version
	soundmanager.init()
	cheats.init()
	--[[End of Loading Resources]]

	screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end
end

function initGameVars()
	-- [[Creating Persistent Timers]]
	ColorManager.init()

	CircleEffect.init()

	Enemy.init()

	enemies.init()

	Shot.init()

	Psychoball.init()

	multtimer = Timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gamelost = false
	}

	function multtimer:funcToCall() -- resets multiplier
		multiplier = 1
		self:stop()
	end

	function multtimer:handlereset()
		self:funcToCall()
	end

	inverttimer = Timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gamelost = false
	}

	function inverttimer:funcToCall() -- disinverts the screen color
		if currentEffect ~= ColorManager.noLSDEffect then 
			soundmanager.setPitch(1)
			timefactor = 1.0
			currentEffect = nil
		end
		self:stop()
	end

	function inverttimer:handlereset()
		self:funcToCall()
	end

	swypetimer = VarTimer:new { -- swypes the screen on menu change
		var = 0,
		speed = 3000,
		pausable = false
	}

	alphatimer = VarTimer:new { --fades out and in the logo
		var = 254,
		speed = 500,
		pausable = false
	}

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

	levels.loadAll()
	levels.reloadPractice()
end

function resetVars()
	if cheats.konamicode then
		ultracounter = 30
		if lives then lives = 30 end
		cheats.konamicode = false
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
	enemies:clear()
	Warning:clear()
	Text:clear()
	ImageBody:clear()
	--[[End of Resetting Paintables]]
	base.clearTable(keyspressed)

	timefactor = 1.0
	multiplier = 1
	gametime = 0
	blastime = 0
	score = 0
	blastscore = 0 --Variavel que dá ultrablast points por pontos
	lifescore = 0

	gamelost = false
	paused = false

	deathmessage = nil
end

function reloadSurvival()
	soundmanager.changeSong(soundmanager.survivalsong)
	if state == survival then Effect:clear() end
	state = survival
	Enemy.addtimer:funcToCall()
	resetVars()
	Timer.closenonessential()

	soundmanager.restart()
	enemies.restartSurvival()
	Enemy.addtimer:start(1.5)
	Enemy.releasetimer:start(.7)

	mouse.setGrab(true)
end

function reloadStory( name )
	if name and name > lastLevel then lastLevel = name levels.reloadPractice() end
	for _, but in pairs(UI.paintables.levelselect) do
		but:close()
	end
	if psycho.pseudoDied then
		psycho.canbehit = true
		psycho.pseudoDied = false
		paintables.psychoeffects = nil
	end
	Effect:clear()
	if state == story and name ~= 'Level 1-1' then
		Timer.closenonessential()
	else
		state = story
		lives = 10
		soundmanager.changeSong(soundmanager.limitlesssong)
		resetVars()
		Timer.closenonessential()

		soundmanager.restart()
		enemies.restartStory()

		mouse.setGrab(true)
	end
	levels.runLevel(name)
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

function getFont(size)
	size = math.floor(size*ratio)
	if fonts[size] then return fonts[size] end
	fonts[size] = graphics.newFont(size)
	return fonts[size]
end

function getCoolFont(size)
	size = math.floor(size*ratio)
	if coolfonts[size] then return coolfonts[size] end
	coolfonts[size] = graphics.newFont('resources/Nevis.ttf', size)
	return coolfonts[size]
end

local moarLSDchance = 3

function lostgame()
	if gamelost or godmode then return end
	local autorestart = state == story and lives > 0
	if not autorestart then
		mouse.setGrab(false)
		FileManager.writeStats()
		soundmanager.fadeout()

		if deathText() == "Supreme." then deathmessage = nil end --make it much rarer
		if state == story and deathText() == "The LSD wears off" then
			deathmessage = "Why are you even doing this?" --or something else
		end

		if deathText() == "The LSD wears off" then
			soundmanager.setPitch(.8)
			deathtexts[1] = "MOAR LSD"
			for i = 1, moarLSDchance do table.insert(deathtexts, "MOAR LSD") end
			currentEffect = ColorManager.noLSDEffect
		elseif deathText() == "MOAR LSD" then
			soundmanager.setPitch(1)
			deathtexts[1] = "The LSD wears off"
			for i = 1, moarLSDchance do table.remove(deathtexts) end
			currentEffect = nil
		end

		gamelost   = true
		pausemessage = nil
	end
	
	timefactor = .05

	psycho:handleDelete()
	gamelostinfo.timeofdeath = totaltime
	gamelostinfo.isrestarting = false
end

function love.draw()
	-- [[Setting camera]]
	graphics.translate(width/2, height/2)
	graphics.rotate(angle.var)
	graphics.translate(-width/2, -height/2)
	graphics.setLineWidth(3)
	graphics.setFont(getFont(12))

	drawBackground()
	
	if splashtimer.running then
		graphics.setColor(255,255,255,255)
		graphics.rectangle("fill", 0, 0, width, height) --background color
		graphics.draw(splash, 100, 80, 0, .55, .55)
		return
	end

	graphics.translate(-swypetimer.var, 0)
	--[[End of setting camera]]
	for _, paintable in pairs(paintables) do
		paintable:drawComponents()
	end

	--[[Drawing Game Objects]]
	if onGame() then
		drawShootingDirection()
		--drawing psychoball
		if not cheats.invisible then
			psycho:draw()
		end
	end
	--[[End of Drawing Game Objects]]

	UI.draw()
	graphics.translate(swypetimer.var, 0)
end

function drawBackground()
	local color = ColorManager.getRawColor(ColorManager.timer.time*.654)
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
	if gamelost or psycho.pseudoDied then return end

	graphics.setLineWidth(1)
	local color = ColorManager.getComposedColor(ColorManager.timer.time + 2)
	graphics.setColor(color)
	if usingjoystick then
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local a1, a2 = joystick.getAxis(1, 4), joystick.getAxis(1, 5)
		if a1 == 0 and a2 == 0 then return end
		local x = a2 > 0 and width or 0
		graphics.line(psycho.x, psycho.y, a2*1200 + psycho.x, a1*1200 + psycho.y)
	else
		graphics.setPixelEffect(base.circleShader)
		graphics.circle("line", mouseX, mouseY, 5)
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local x = mouseX > psycho.x and width or 0
		graphics.setPixelEffect()
		graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((mouseY - psycho.y)/(mouseX - psycho.x)))
	end
	graphics.setPixelEffect(base.circleShader)
end

playtexts = {"Start", "START", "Start Mission", "game.\nplay()", "Don't Click Me", "Give me  BALLS"}

pausetexts = {"to surrender","to go back","to give up","to admit defeat","to /ff", "to RAGE QUIT","if you can't handle the balls"}

deathtexts = {"The LSD wears off", "Game Over", "No one will\n      miss you", "You now lay\n   with the dead", "Yo momma so fat\n   you died",
"You ceased to exist", "Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?", "All your base\n     are belong to BALLS",
"You wake up and\n     realize it was all a nightmare", "MIND BLOWN","Just one more","USPGameDev Rulez","A winner is not you","Have a nice death",
"There is no cake\n   also you died","You have died of\n      dysentery","You failed", "Epic fail", "BAD END",
"YOU WIN!!! \n                       nope, chuck testa","Supreme.","Embrace your defeat","Balls have no mercy","You have no balls left","Nevermore...",
"Rest in Peace","Die in shame","You've found your end", "KIA", "Status: Deceased", "Requiescat in Pace", "Valar Morghulis", "What is dead may never die","Mission Failed"}

function deathText( n )
	deathmessage = n and deathtexts[n] or (deathmessage or deathtexts[math.random(#deathtexts)])
	return deathmessage
end

function pauseText()
	pausemessage = pausemessage or pausetexts[math.random(#pausetexts)]
	return pausemessage
end

function playText()
	playmessage = playtexts[math.random(#playtexts)]
	return playmessage
end


function love.update(dt)
	if dt > 0.03333 then dt = 0.03333 end
	totaltime = totaltime + dt
	mouseX, mouseY = mouse.getPosition()
	mouseX = mouseX + swypetimer.var
	isPaused = (paused or onMenu())

	Timer.updatetimers(dt, timefactor, isPaused, gamelost)
	UI.update(dt)
	
	dt = dt * timefactor
	
	if paused then return end
	if onGame() then
		psycho:update(dt)
	end

	updateBodies(dt)
end

function updateBodies( dt )
	for i, v in pairs(paintables) do
		if not v.updateComponents then table.foreach(v, print) error() end
		v:updateComponents(dt)
	end
end

function love.mousepressed(x, y, btn)
	x, y  = x/ratio, y/ratio
	if btn == 'l' and onGame() and not (gamelost or paused or psycho.pseudoDied) then
		Shot.timer:start(Shot.timer.timelimit) --starts shooting already
	end
	UI.mousepressed(x + swypetimer.var, y, btn)
end

function love.mousereleased(x, y, btn)
	x, y  = x/ratio, y/ratio		
	UI.mousereleased(x + swypetimer.var, y, btn)
	if btn == 'l' and onGame() then
		Shot.timer:stop()
	end
end

function addscore(x)
	if not gamelost then
		score = score + x
		blastscore = blastscore + x
		lifescore = lifescore + x
		if blastscore >= (state == survival and 7000 or 2000) then
			blastscore = blastscore - (state == survival and 7000 or 2000)
			ultracounter = ultracounter + 1
		end
		if state == story and lifescore >= 15000 then
			lifescore = lifescore - 15000
			lives = lives + 1
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

	if (key == 'escape' or key == 'p') and onGame() and not gamelost then
		pausemessage = nil --resets pauseText()
		paused = not paused --pauses or unpauses
		mouse.setGrab(not paused) --releases the mouse if paused
	end

	if not gamelost and onGame() then 
		psycho:keypressed(key)
	end

	UI.keypressed(key)
	cheats.keypressed(key)
	soundmanager.keypressed(key)

end

function love.keyreleased(key)
	if not keyspressed[key] then return
	else keyspressed[key] = false end

	if not gamelost and onGame() then
		psycho:keyreleased(key)
	end
	
	if key == 'scrollock' then 
		graphics.newScreenshot():encode('screenshot_' .. screenshotnumber .. '.png')
		screenshotnumber = screenshotnumber + 1
	end
end

function love.focus(f)
	if onGame() and not (f or gamelost) then paused = true end
end

function love.quit()
	FileManager.writeConfig()
	FileManager.writeStats()
end