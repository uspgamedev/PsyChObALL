require "base"
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
require "timer"
require "vartimer"
require "list"
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

	mouse.setGrabbed(false)
end

function initBase()
	-- [[Initing Variables]]
	v = 240 --main velocity of everything
	totaltime = 0
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
	usingjoystick = false --joystick.isOpen(1)

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
	shot:paintOn(paintables)
	enemy:paintOn(paintables)
	effect:paintOn(paintables)
	enemies:paintOn(paintables)
	warning:paintOn(paintables)
	circleEffect:paintOn(paintables)
	text:paintOn(paintables)
	imagebody:paintOn(paintables)
	table.sort(paintables, function(a, b) return a.ord < b.ord end)

	UI.self.paintables = {} --[[If you just use UI.paintables = {} it actually
		sets _G.paintables because of base.globalize]]
	button:paintOn(UI.paintables)

	bestscore, besttime, bestmult = 0, 0, 0
	lastLevel = 'Level 1-1'
	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	filemanager.readconfig()
	filemanager.readstats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage 'resources/LogoBeta.png'
	splash = graphics.newImage 'resources/Marvellous Soft.png'
	splashtimer = timer:new{timelimit = 1.75, running = true, persistent = true, pausable = false, funcToCall = function(t) t:remove() end}

	window.setIcon(graphics.newImage('resources/IconBeta.png'):getData())
	version = '1.0.0'
	latest = base.getLatestVersion() or version
	soundmanager.init()
	cheats.init()
	--[[End of Loading Resources]]

	screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end
end

function initGameVars()
	-- [[Creating Persistent Timers]]
	colortimer = timer:new{
		timelimit  = 300,
		pausable   = false,
		persistent = true,
		running = true
	}

	circleEffect.init()

	enemy.init()

	enemies.init()

	shot.init()

	psychoball.init()

	multtimer = timer:new {
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

	inverttimer = timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gamelost = false
	}

	function inverttimer:funcToCall() -- disinverts the screen color
		if currentEffect ~= noLSDeffect then 
			soundmanager.setPitch(1)
			timefactor = 1.0
			currentEffect = nil
		end
		self:stop()
	end

	function inverttimer:handlereset()
		self:funcToCall()
	end

	swypetimer = vartimer:new { -- swypes the screen on menu change
		var = 0,
		speed = 3000,
		pausable = false
	}

	alphatimer = vartimer:new { --fades out and in the logo
		var = 255,
		speed = 300,
		pausable = false
	}

	angle = vartimer:new {
		var = 0,
		speed = 1,
		pausable = false
	}
	-- [[End of Creating Persistent Timers]]

	psycho = psychoball:new{
		position = vector:new{width/2,height/2}
	}
	
	enemylist = list:new{}
	auxspeed = vector:new {}
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
	
	enemylist:clear()
	auxspeed:reset()
	--[[Resetting Paintables]]
	shot:clear()
	if notclearcircleeffect then notclearcircleeffect = false
	else circleEffect:clear() end
	enemy:clear()
	enemies:clear()
	warning:clear()
	text:clear()
	imagebody:clear()
	--[[End of Resetting Paintables]]
	cleartable(keyspressed)

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
	if state == survival then effect:clear() end
	state = survival
	enemy.addtimer:funcToCall()
	resetVars()
	timer.closenonessential()

	soundmanager.restart()
	enemies.restartSurvival()
	enemy.addtimer:start(2)
	enemy.releasetimer:start(1.5)

	mouse.setGrabbed(true)
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
	effect:clear()
	if state == story and name ~= 'Level 1-1' then
		timer.closenonessential()
	else
		state = story
		lives = 10
		soundmanager.changeSong(soundmanager.limitlesssong)
		resetVars()
		timer.closenonessential()

		soundmanager.restart()
		enemies.restartStory()

		mouse.setGrabbed(true)
	end
	levels.runLevel(name)
end


function onMenu()
	return state < 10
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
		mouse.setGrabbed(false)
		filemanager.writestats()
		soundmanager.fadeout()

		if deathText() == "Supreme." then deathmessage = nil end --make it much rarer
		if state == story and deathText() == "The LSD wears off" then
			deathmessage = "Why are you even doing this?" --or something else
		end

		if deathText() == "The LSD wears off" then
			soundmanager.setPitch(.8)
			deathtexts[1] = "MOAR LSD"
			for i = 1, moarLSDchance do table.insert(deathtexts, "MOAR LSD") end
			currentEffect = noLSDeffect
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

	colorwheel(colortimer.time*.654)
	maincolor[1] = maincolor[1] / 3
	maincolor[2] = maincolor[2] / 3
	maincolor[3] = maincolor[3] / 3
	applyeffect(nil, maincolor)
	maincolor[1] = maincolor[1] / 4
	maincolor[2] = maincolor[2] / 4
	maincolor[3] = maincolor[3] / 4
	graphics.setColor(maincolor)
	if splashtimer.running then
		graphics.setColor(255,255,255,255)
		graphics.rectangle("fill", 0, 0, width, height) --background color
		graphics.draw(splash, 100, 80, 0, .55, .55)
		return
	end
	graphics.rectangle("fill", 0, 0, width, height) --background color
	graphics.translate(math.floor(-swypetimer.var), 0)
	--[[End of setting camera]]
	for i, v in pairs(paintables) do
		for j, m in pairs(v) do
			m:draw()
		end
	end

	--[[Drawing Game Objects]]
	if onGame() then
		graphics.setColor(color(colortimer.time * 1.4))
		graphics.setLineWidth(1)
		--drawing mouse line
		line()
		--drawing psychoball
		if not cheats.invisible then
			psycho:draw()
		end
	end
	--[[End of Drawing Game Objects]]

	UI.draw()
end

function color( x, alpha, effect )
	return applyeffect(effect, colorwheel(x, alpha))
end

function inverteffect( color )
	color[1], color[2], color[3] =
		255 - color[1], 255 - color[2], 255 - color[3]
	return color
end

function noLSDeffect( color )
	local gray = (color[1] + color[2] + color[3]) / 3
	color[1], color[2], color[3] = 
		color[1] + (gray - color[1])/1.1,
		color[2] + (gray - color[2])/1.1,
		color[3] + (gray - color[3])/1.1
	return color
end

function sincityeffect( color )
	local gray = (color[1] + color[2] + color[3]) / 3
	color[1], color[2], color[3] =  gray + (255 - gray)/5, 0, 0
	return color
end

function getColorEffect( r, g, b, change )
	change = change or 60
	if type(r) == 'table' then --consider all vartimers
		if type(change) ~= 'table' then change = {var = change} end
		return function ( color )
			color[1], color[2], color[3] = 
					color[1]*change.var/255 + math.min(math.max(r.var - change.var/2, 0), 255 - change.var),
					color[2]*change.var/255 + math.min(math.max(g.var - change.var/2, 0), 255 - change.var),
					color[3]*change.var/255 + math.min(math.max(b.var - change.var/2, 0), 255 - change.var)
			return color
		end
	else --conside all numbers
		local consteffect = change/255
		r = math.min(math.max(r - change/2, 0), 255 - change)
		g = math.min(math.max(g - change/2, 0), 255 - change)
		b = math.min(math.max(b - change/2, 0), 255 - change)
		return function ( color )
			color[1], color[2], color[3] = 
					color[1]*consteffect + r,
					color[2]*consteffect + g,
					color[3]*consteffect + b
			return color
		end
	end
end

function applyeffect( effect, color )
	return (effect or currentEffect) and (effect or currentEffect)(color) or color
end

colorcycle = 10 
local xt = colorcycle
maincolor = {0,0,0,0}
function colorwheel(x, alpha)
	x = x % colorcycle
	local r, g, b
	if x <= xt / 3 then
		r = 100					  -- 100%
		g = 100 * x / (xt / 3) -- 0->100%
		b = 0						  -- 0%
	elseif x <= xt / 2 then
		r = 100 * (1 - ((x - xt / 3) / (xt / 2 - xt / 3)))	-- 100->0%
		g = 100 - 20 * ((x - xt / 3) / (xt / 2 - xt / 3))	-- 100->80%
		b = 05															-- 0%
	elseif x <= 7 * xt / 12 then
		r = 05																-- 0%
		g = 80 - 20 * ((x - xt / 2) / (7 * xt / 12 - xt / 2))	-- 80->60%
		b = 60 * ((x - xt / 2) / (7 * xt / 12 - xt / 2))		-- 0->60%
	elseif x <= 255 * xt / 360 then
		r = 11 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12))		 -- 0->11%
		g = 60 - 49 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->11%
		b = 60 + 10 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->70%
	elseif x <= 318 * xt / 360 then
		r = 11 + 59 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 11->70%
		g = 11 * (1 - ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))) -- 11->0%
		b = 70 - 10 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 70->60%
	else
		r = 70 + 30 * ((x - 318 * xt / 360) / (xt - 318 * xt / 360))  -- 70->100%
		g = 0 																		  -- 0%
		b = 60 * (1 - ((x - 318 * xt / 360) / (xt - 318 * xt / 360))) -- 60->0%
	end
	maincolor[1], maincolor[2], maincolor[3], maincolor[4] = r * 2.55, g * 2.55, b * 2.55, alpha or 255
	return maincolor
end


function line()
	if gamelost or psycho.pseudoDied then return end
	graphics.setColor(color(colortimer.time + 2))
	if usingjoystick then
		maincolor[4] = 60 -- alpha
		graphics.setColor(maincolor)
		local a1, a2 = joystick.getAxis(1, 4), joystick.getAxis(1, 5)
		if a1 == 0 and a2 == 0 then return end
		local x = a2 > 0 and width or 0
		graphics.line(psycho.x, psycho.y, a2*1200 + psycho.x, a1*1200 + psycho.y)
	else
		local mx, my = mouse.getPosition()
		graphics.circle("line", mx, my, 5)
		maincolor[4] = 60 -- alpha
		graphics.setColor(maincolor)
		local x = mx > psycho.x and width or 0
		graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((my - psycho.y)/(mx - psycho.x)))
	end
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

local todelete = {}

function love.update(dt)
	totaltime = totaltime + dt
	mouseX, mouseY = mouse.getPosition()
	mouseX = mouseX + swypetimer.var
	isPaused = (paused or onMenu())

	timer.updatetimers(dt, timefactor, isPaused, gamelost)
	UI.update(dt)
	
	dt = dt * timefactor
	
	if paused then return end
	if onGame() and not gamelost then
		gametime = gametime + dt
		blastime = blastime + dt
		if blastime >= 30 and state == survival then
			blastime = blastime - 30
			ultracounter = ultracounter + 1
		end
	end

	psycho:update(dt)

	for i, v in pairs(paintables) do
		for j, m in pairs(v) do
			m:update(dt)
			if m.delete then
				table.insert(todelete, j)
			end
		end

		local n
		for k = #todelete, 1, -1 do
			n = todelete[k]
			todelete[k] = nil
			v[n]:handleDelete()
			v[n] = nil
		end
	end
end

function love.mousepressed(x, y, btn)
	x, y  = x/ratio, y/ratio
	if btn == 'l' and onGame() and not (gamelost or paused or psycho.pseudoDied) then
		shot.timer:start(shot.timer.timelimit) --starts shooting already
	end
	UI.mousepressed(x + swypetimer.var, y, btn)
end

function love.mousereleased(x, y, btn)
	x, y  = x/ratio, y/ratio		
	UI.mousereleased(x + swypetimer.var,y,button)
	if btn == 'l' and onGame() then
		shot.timer:stop()
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
		if state == story and lifescore >= 10000 then
			lifescore = lifescore - 10000
			lives = lives + 1
		end
	end
end

function love.joystickpressed( joynum, button )
	if not usingjoystick then return end
	psycho:joystickpressed(joynum, button)
end

function love.joystickreleased( joynum, button )
	if not usingjoystick then return end
	psycho:joystickreleased(joynum, button)
end

function love.keypressed(key, isRepeat)
	if isRepeat then return end
	keyspressed[key] = true

	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if (key == 'escape' or key == 'p') and onGame() and not gamelost then
		pausemessage = nil --resets pauseText()
		paused = not paused --pauses or unpauses
		mouse.setGrabbed(not paused) --releases the mouse if paused
	end

	if not gamelost and onGame() then 
		psycho:keypressed(key)
	end

	UI.keypressed(key)
	cheats.keypressed(key)
	soundmanager.keypressed(key)

end

function love.keyreleased(key, isRepeat)
	if isRepeat then return end
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
	filemanager.writeconfig()
	filemanager.writestats()
end