width, height = 1080, 720

require "base"
require "userinterface"
require "body"
require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"
require "vartimer"
require "list"
require "bosses"
require "psychoball"
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
	mainmenu = 1 -- mainmenu
	tutorialmenu = 2
	achievmenu  = 0 -- Tela de achievements
	survivor = 10 -- modo de jogo survivor
	state = mainmenu
	sqrt2 = math.sqrt(2)
	fonts = {}
	coolfonts = {}
	resetted = false

	paintables = {}
	paintables[1] = circleEffect.bodies
	paintables[2] = shot.bodies
	paintables[3] = enemy.bodies
	paintables[4] = effect.bodies
	paintables[5] = bosses.bodies

	rawset(UI, 'paintables', {}) --[[If you just use UI.paintables = {} it actually
		sets _G.paintables because of base.globalize]]
	UI.paintables[1] = button.bodies

	bestscore, besttime, bestmult = 0, 0, 0
	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	filemanager.readconfig()
	filemanager.readstats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage('resources/LogoBeta.png')

	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))
	version = '0.9.0\n'
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
		timelimit  = 10,
		pausable   = false,
		persistent = true,
		running = true
	}

	circleEffect.init()

	enemy.init()

	bosses.init()

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
	
	enemylist = list:new{}
	auxspeed = vector:new {}
	keyspressed = {}
	timefactor = 1.0
end

function resetVars()
	ultracounter = 3
	
	enemylist:clear()
	auxspeed:reset()
	--[[Resetting Paintables]]
	cleartable(shot.bodies)
	cleartable(effect.bodies)
	cleartable(circleEffect.bodies)
	cleartable(enemy.bodies)
	cleartable(bosses.bodies)
	--[[End of Resetting Paintables]]
	cleartable(keyspressed)
	

	psycho = psychoball:new{
		position = psycho and psycho.position or vector:new{513,360}
	}

	timefactor = 1.0
	multiplier = 1
	totaltime = 0
	blastime = 0
	score = 0
	blastscore = 0 --Variavel que dá ultrablast points por pontos

	gamelost = false
	paused = false

	deathmessage = nil
end

function cleartable( t )
	for k in pairs(t) do t[k] = nil end
end

function reloadGame()	
	enemy.addtimer:funcToCall()
	resetVars()
	timer.closenonessential()

	soundmanager.restart()
	bosses.restart()
	enemy.addtimer:start(2)
	enemy.releasetimer:start(1.5)

	mouse.setGrab(true)
end

function onMenu()
	return state < 10
end

function onGame()
	return state >= 10 and state < 20
end

function getFont(size)
	if fonts[size] then return fonts[size] end
	fonts[size] = graphics.newFont(size)
	return fonts[size]
end

function getCoolFont(size)
	if coolfonts[size] then return coolfonts[size] end
	coolfonts[size] = graphics.newFont('resources/Nevis.ttf', size)
	return coolfonts[size]
end

local moarLSDchance = 3

function lostgame()
	if gamelost then return end
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

	psycho:handleDelete() --not really deleting but anyway
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
	applyeffect(maincolor)
	maincolor[1] = maincolor[1] / 4
	maincolor[2] = maincolor[2] / 4
	maincolor[3] = maincolor[3] / 4
	graphics.setColor(maincolor)
	graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight()) --background color
	--[[End of setting camera]]

	--[[Drawing Game Objects]]
	if onGame() then
		for i, v in pairs(paintables) do
			for j, m in pairs(v) do
				m:draw()
			end
		end

		graphics.setColor(color(colortimer.time * 1.4))
		graphics.setLine(1)
		-- drawing enemy arcs
		for i = enemylist.first, enemylist.last - 1 do
			graphics.arc("line", enemylist[i].x, enemylist[i].y, 30, enemylist[i].arctan - .15, enemylist[i].arctan + .15)
		end
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

function color( ... )
	return applyeffect(colorwheel(...))
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

function applyeffect( color )
	return currentEffect and currentEffect(color) or color
end

local xt = 10 -- = colortimer.timelimit
maincolor = {0,0,0,0}
function colorwheel(x, alpha)
	x = x % colortimer.timelimit
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
	local mx, my = mouse.getX(), mouse.getY()
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
	playmessage = playmessage or playtexts[math.random(#playtexts)]
	return playmessage
end

local todelete = {}

function love.update(dt)
	isPaused = (paused or onMenu())

	timer.updatetimers(dt, timefactor, isPaused, gamelost)
	
	dt = dt * timefactor
	
	if isPaused then return end
	if not gamelost then
		totaltime = totaltime + dt
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
	UI.mousepressed(x, y, btn)
	if paused then return end
	if btn == 'l' and onGame() and not gamelost then
		shot.timer:start(shot.timer.timelimit) --starts shooting already
	end
end

function love.mousereleased(x, y, btn)
	button.mousereleased(x,y,button)
	if btn == 'l' and onGame() then
		shot.timer:stop()
	end
end

function shoot(x, y)
	local diffx = x - psycho.x
	local diffy = y - psycho.y
	local Vx = sign(diffx) * math.sqrt((9 * v^2 * diffx^2) / (diffx^2 + diffy^2))
	local Vy = sign(diffy) * math.sqrt((9 * v^2 * diffy^2) / (diffx^2 + diffy^2))
	table.insert(shot.bodies, shot:new {
		position = psycho.position:clone(),
		speed	 = vector:new {Vx, Vy}
		})
end

function sign(a)
	return a == 0 and 0 or a > 0 and 1 or -1 
end

function addscore(x)
	if not gamelost then
		score = score + x
		blastscore = blastscore + x
		if blastscore >= 500 then
			blastscore = blastscore - 500
			ultracounter = ultracounter + 1
		end
	end
end

function love.keypressed(key)
	keyspressed[key] = true

	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if (key == 'escape' or key == 'p') and not (gamelost or onMenu()) then
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
	if not (f or gamelost or onMenu()) then paused = true end
end

function love.quit()
	filemanager.writeconfig()
end