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

	mouse.setGrab(false)
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
	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	filemanager.readconfig()
	filemanager.readstats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage('resources/LogoBeta.png')

	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))
	version = '0.9.0'
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
		onceonly	  = true,
		persistent = true,
		works_on_gamelost = false
	}

	function multtimer:funcToCall() -- resets multiplier
		multiplier = 1
	end

	function multtimer:handlereset()
		self:stop() 
		self:funcToCall()
	end

	inverttimer = timer:new {
		timelimit  = 2.2,
		onceonly   = true,
		persistent = true,
		works_on_gamelost = false
	}

	function inverttimer:funcToCall() -- disinverts the screen color
		if currentEffect ~= noLSDeffect then 
			soundmanager.setPitch(1)
			timefactor = 1.0
			currentEffect = nil
		end
	end

	function inverttimer:handlereset()
		self:stop()
		self:funcToCall()
	end

	swypetimer = vartimer:new { -- swypes the screen on menu change
		var = 0,
		speed = 3000
	}

	alphatimer = vartimer:new { --fades out and in the logo
		var = 255,
		speed = 300
	}

	angle = vartimer:new {
		var = 0,
		speed = 1
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
end

function resetVars()
	if cheats.konamicode then
		ultracounter = 30
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

	gamelost = false
	paused = false

	deathmessage = nil
end

function reloadSurvival()
	soundmanager.changeSong(soundmanager.gamesong)
	if state == survival then effect:clear() end
	state = survival
	enemy.addtimer:funcToCall()
	resetVars()
	timer.closenonessential()

	soundmanager.restart()
	enemies.restartSurvival()
	enemy.addtimer:start(2)
	enemy.releasetimer:start(1.5)

	mouse.setGrab(true)
end

function reloadStory( name )
	for _, but in pairs(UI.paintables.levelselect) do
		but:close()
	end
	if state == story then effect:clear() end
	state = story
	lives = 3
	soundmanager.changeSong(soundmanager.gamesong)
	notclearcircleeffect = true
	resetVars()
	timer.closenonessential()

	soundmanager.restart()
	enemies.restartStory()

	mouse.setGrab(true)

	levels.runLevel(name)
end

function selectLevel()
	state = levelselect
	UI.paintables.levelselect[1].alphafollows:setAndGo(0, 255)
	for _, but in pairs(UI.paintables.levelselect) do
		but:start()
	end

	mouse.setGrab(false)
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
	if gamelost then return end
	if respawn then return end
	mouse.setGrab(false)
	soundmanager.fadeout()
	filemanager.writestats()

	if deathText() == "Supreme." then deathmessage = nil end --make it much rarer

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
	timefactor = .05
	pausemessage = nil

	if levels.currentLevel then
		for _, t in ipairs(levels.currentLevel.timers_) do
			t:stop()
		end
	end

	psycho:handleDelete()
	gamelostinfo.timeofdeath = totaltime
	gamelostinfo.isrestarting = false
end

function love.draw()
	-- [[Setting camera]]
	graphics.translate(width/2, height/2)
	graphics.rotate(angle.var)
	graphics.translate(-width/2, -height/2)
	graphics.setLine(3)
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
		graphics.setLine(1)
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
	local consteffect = change/255
	if type(r) == 'table' then --consider all vartimers
		return function ( color )
			color[1], color[2], color[3] = 
					color[1]*consteffect + math.min(math.max(r.var - change/2, 0), 255 - change),
					color[2]*consteffect + math.min(math.max(g.var - change/2, 0), 255 - change),
					color[3]*consteffect + math.min(math.max(b.var - change/2, 0), 255 - change)
			return color
		end
	else --conside all numbers
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
	if gamelost then return end
	local mx, my = mouse.getPosition()
	graphics.setColor(color(colortimer.time + 2))
	graphics.circle("line", mx, my, 5)
	maincolor[4] = 60 -- alpha
	graphics.setColor(maincolor)
	local x = mx > psycho.x and width or 0
	graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((my - psycho.y)/(mx - psycho.x)))
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
		if blastime >= 30 then
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
	if btn == 'l' and onGame() and not (gamelost or paused) then
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

function shoot(x, y)
	local diffx = x - psycho.x
	local diffy = y - psycho.y
	local Vx = sign(diffx) * math.sqrt((9 * v^2 * diffx^2) / (diffx^2 + diffy^2))
	local Vy = sign(diffy) * math.sqrt((9 * v^2 * diffy^2) / (diffx^2 + diffy^2))
	shot:new {
		position = psycho.position:clone(),
		speed	 = vector:new {Vx, Vy}
		}:register()
end

function sign(a)
	return a == 0 and 0 or a > 0 and 1 or -1 
end

function addscore(x)
	if not gamelost then
		score = score + x
		blastscore = blastscore + x
		if blastscore >= 7000 then
			blastscore = blastscore - 500
			ultracounter = ultracounter + 1
		end
	end
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
	filemanager.writeconfig()
end