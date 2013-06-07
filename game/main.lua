width, height = 1080, 720

require "base"
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
	initMenu()

	mouse.setGrab(false)
end

function initBase()

	-- [[Initing Variables]]
	v = 240 --main velocity of everything
	mainmenu = 1 -- mainmenu
	tutorialmenu = 2
	achmenu  = 0 -- Tela de achievements
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

	paintablesMenu = {}
	paintablesMenu[1] = button.bodies

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

function initMenu()
	playbutton = button:new{
		size = 100,
		position = vector:new {width/2, 510},
		text = playText(),
		fontsize = 40
	}

	function playbutton:pressed()
		state = survivor
		alphatimer:setAndGo(255, 0)
		mouse.setGrab(true)
		reloadGame()
		button.bodies['play'] = nil
		neweffects(self, 100)
	end

	button.bodies['play'] = playbutton

	--[[local rightbutton = button:new {
		size = 80,
		position = vector:new {width - 100, height - 100},
		text = "Controls",
		fontsize = 20
	}

	function rightbutton:pressed()
		-- go right
	end]] --TODO
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
	blastscore = 0 --Variavel que da ultrablast points por pontos

	gamelost = false
	paused = false

	deathmessage = nil
end

function cleartable( t )
	for k in pairs(t) do t[k] = nil end
end

function reloadGame()
	resetVars()
	timer.closenonessential()
	
	enemy.addtimer:funcToCall()

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

local maincolor = {0,0,0,0}

function love.draw()
	-- [[Setting camera]]
	graphics.translate(width/2, height/2)
	graphics.rotate(angle.var)
	graphics.translate(-width/2, -height/2)
	graphics.setLine(3)
	graphics.setFont(getFont(12))

	colorwheel(maincolor, colortimer.time*.654)
	maincolor[1] = maincolor[1] / 3
	maincolor[2] = maincolor[2] / 3
	maincolor[3] = maincolor[3] / 3
	applyeffect(maincolor)
	maincolor[1] = maincolor[1] / 6
	maincolor[2] = maincolor[2] / 6
	maincolor[3] = maincolor[3] / 6
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

		graphics.setColor(color(maincolor, colortimer.time * 1.4))
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

	--[[Drawing On-Game Info]]
	if onGame() then
		graphics.setFont(getCoolFont(22))
		graphics.print(string.format("%.0f", score), 68, 20)
		graphics.print(string.format("%.1fs", totaltime), 68, 42)
		graphics.setFont(getFont(12))
		graphics.print("Score:", 25, 24)
		graphics.print("Time:", 25, 48)
		graphics.print(string.format("Best Score: %0.f", math.max(bestscore, score)),     25, 68)
		graphics.print(string.format("Best Time: %.1fs", math.max(besttime,  totaltime)), 25, 85)
		graphics.print(string.format("Best Mult: x%.1f", math.max(bestmult,  multiplier)), 965, 83)
		graphics.setFont(getFont(14))
		graphics.print("ulTrAbLaST:", 25, 105)
		graphics.setFont(getCoolFont(20))
		graphics.print(string.format("%d", ultracounter), 110, 100)
		graphics.setFont(getFont(20))
		graphics.print("___________", 25, 106)
		graphics.setFont(getCoolFont(40))
		graphics.print(string.format("x%.1f", multiplier), 950, 35)
		
		graphics.setFont(getFont(12))
		if cheats.devmode then graphics.print("dev mode on!", 446, 5) end
		if cheats.invisible then graphics.print("Invisible mode on!", 432, 18) end
		if cheats.image.enabled then
			if 	 cheats.image.pass == 'yan' then graphics.print("David Robert Jones mode on!", 395, 32)
			elseif cheats.image.pass == 'pizza' then graphics.print("Italian mode on!", 438, 32) 
			elseif cheats.image.pass == 'rica' then graphics.print("Richard mode on!", 433, 32)
			elseif cheats.image.pass == 'rika' then graphics.print("Detective mode on!", 428, 32) end
		end
	end
	--[[End of Drawing On-Game Info]]

	--[[Drawing Things that show up on every page]]
	graphics.setColor(color(maincolor, colortimer.time))
	graphics.print(string.format("FPS:%.0f", love.timer.getFPS()), 1000, 10)
	maincolor[4] = 70 --alpha
	graphics.setColor(maincolor)
	soundmanager.drawSoundIcon(1030, 675)
	--[[End of Drawing Things that show up on every page]]

	--[[Drawing Death Screen]]
	if gamelost and onGame() then
		graphics.setColor(color(maincolor, colortimer.time - colortimer.timelimit / 2))
		if cheats.wasdev then
			graphics.setFont(getCoolFont(20))
			graphics.print("Your scores didn't count, cheater!", 382, 215)
		else
			if besttime == totaltime then
				graphics.setFont(getFont(35))
				graphics.print("You beat the best time!", 260, 100)
			end	
			if bestscore == score then
				graphics.setFont(getFont(35))
				graphics.print("You beat the best score!", 290, 140)
			end
			if bestmult == multiplier then
				graphics.setFont(getFont(35))
				graphics.print("You beat the best multiplier!", 320, 180)
			end
		end
		graphics.setFont(getCoolFont(40))
		graphics.print(deathText(), 270, 300)
		graphics.setFont(getFont(30))
		graphics.print(string.format("You lasted %.1fsecs", totaltime), 486, 450)
		graphics.setFont(getCoolFont(23))
		graphics.print("Press r to retry", 300, 645)
		graphics.setFont(getCoolFont(18))
		graphics.print("Press b", 580, 650)
		graphics.print(pauseText(), 649, 650)
	end
	--[[End of Drawing Death Screen]]

	--[[Drawing Menu]]
	if alphatimer.var > 0 then
		graphics.setColor(color(maincolor, colortimer.time - colortimer.timelimit / 2))
		graphics.push()
		graphics.translate(math.floor(-swypetimer.var), 0)
		--drawing menu paintables
		for _,v in pairs(paintablesMenu) do
			for k, p in pairs(v) do
				p:draw()
			end
		end
		--drawing mainmenu
		graphics.setFont(getFont(12))
		graphics.setColor(color(maincolor, colortimer.time * 0.856, alphatimer.var))
		graphics.print("v" .. version, 513, 687)
		graphics.print('Write "reset" to delete stats' , 15, 10)
		if resetted then graphics.print("~~stats deleted~~", 25, 23) end

		if latest ~= version then
			graphics.print("Version " .. latest, 422, 700)
			graphics.print("is available to download!", 510, 700)
		end

		graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)

		graphics.setColor(color(maincolor, colortimer.time * 4.5 + .54, alphatimer.var))
		graphics.draw(logo, 120, 75, nil, 0.25, 0.20)
		graphics.setFont(getFont(12))
		--end of mainmenu

		graphics.translate(width, 0)
		--drawing tutorialmenu
		graphics.setColor(color(maincolor, colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("CONTROLS", 380, 36)
		graphics.setFont(getCoolFont(40))
		graphics.print("Survivor Mode:", 170, 350)
		graphics.setColor(color(maincolor, colortimer.time * 2.5 + .54))
		graphics.setFont(getCoolFont(20))
		graphics.print("You get points when", 540, 425)
		graphics.print("  you kill an enemy", 570, 455)
		graphics.print("Survive as long as you can!", 152, 440)
		graphics.print("You get one more ulTrAbLaST for every 30 seconds you survive!", 182, 500)
		graphics.print("You have a limited amount of ulTrAbLaSTs to use", 540, 230)
		graphics.print("You get one more ulTrAbLaST for every 1000 points!", 540, 270)
		graphics.setFont(getCoolFont(20))
		graphics.print("Use WASD or arrows to move", 152, 170)
		graphics.print("Click or hold the left mouse button to shoot", 540, 170)
		graphics.print("Hold space to charge", 70, 252)
		graphics.setFont(getCoolFont(18))
		graphics.print("Click or press the left arrow key to go back", 670, 645)
		graphics.setFont(getCoolFont(35))
		graphics.setColor(color(maincolor, colortimer.time * 0.856))
		graphics.print("ulTrAbLaST", 290, 242)
		graphics.setColor(color(maincolor, colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 10)
		graphics.circle("fill", 520, 450, 10)
		graphics.circle("fill", 160, 510, 10)
		graphics.circle("fill", 520, 240, 10)
		graphics.circle("fill", 520, 280, 10)
		graphics.setColor(color(maincolor, colortimer.time * 7.5 + .54))
		graphics.circle("fill", 520, 180, 10)
		graphics.circle("fill", 130, 450, 10)
		graphics.circle("fill", 50, 263, 10)
		--end of tutorialmenu

		graphics.translate(-2 * width, 0)
		--drawing achievmentsmenu
		graphics.setColor(color(maincolor, colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("ACHIEVEMENTS", 340, 36)
		graphics.setColor(color(maincolor, colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 5)
		graphics.setColor(color(maincolor, colortimer.time * 7.5 + .54))
		graphics.circle("fill", 130, 210, 5)
		graphics.setFont(getCoolFont(18))
		graphics.print("Click or press the right arrow key to go back", 670, 645)
		--end of achievmentsmenu

		graphics.pop()
	end
	--[[End of Drawing Menu]]
	
	--[[Drawing Pause Menu]]
	if paused and onGame() then
		graphics.setColor(color(maincolor, colortimer.time - colortimer.timelimit / 2))
		graphics.setFont(getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(getCoolFont(20))
		graphics.print("Press b", 603, 550)
		graphics.print(pauseText(), 682, 550)
		graphics.setFont(getFont(12))
	end
	--[[End of Drawing Pause Menu]]
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
function colorwheel(color, x, alpha)
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
	color[1], color[2], color[3], color[4] = r * 2.55, g * 2.55, b * 2.55, alpha or 255
	return color
end


function line()
	if gamelost then return end
	local mx, my = mouse.getX(), mouse.getY()
	graphics.setColor(color(maincolor, colortimer.time + 2))
	graphics.circle("line", mx, my, 5)
	maincolor[4] = 60 -- alpha
	graphics.setColor(maincolor)
	local x = mx > psycho.x and width or 0
	graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((my - psycho.y)/(mx - psycho.x)))
end

playtexts = {"go", "run", "are you ready?", "start mission", "game.\nplay()", "don't click me", "ready, set, GO!"}

pausetexts = {"to surrender","to go back","to give up","to admit defeat","to /ff", "to RAGE QUIT","if you can't handle the balls"}

deathtexts = {"The LSD wears off", "Game Over", "No one will\n      miss you", "You now lay\n   with the dead", "Yo momma so fat\n   you died",
"You ceased to exist", "Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?", "All your base\n     are belong to BALLS",
"You wake up and\n     realize it was all a nightmare", "MIND BLOWN","Just one more","USPGameDev Rulez","A winner is not you","Have a nice death",
"There is no cake\n   also you died","You have died of\n      dysentery","You failed", "Epic fail", "BAD END",
"YOU WIN!!! \n                       nope, chuck testa","Supreme.","Embrace your defeat","Balls have no mercy","You have no balls left","Nevermore...",
"Rest in Peace","Die in shame","You've found your end", "KIA", "Status: Deceased", "Requiescat in Pace"}

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
	button.mousepressed(x,y,button)
	if paused then return end

	if btn == 'r' and state == mainmenu then
		swypetimer:setAndGo(0, width)
		state = tutorialmenu
	elseif (btn == 'l' or btn == 'r') and state == tutorialmenu then
		swypetimer:setAndGo(width, 0)
		state = mainmenu
	elseif (btn == 'l' or btn == 'r') and state == achmenu then
		swypetimer:setAndGo(-width, 0)
		state = mainmenu
	elseif btn == 'l' and onGame() and not gamelost then
		shoot(x, y)
		shot.timer:start()
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

resetpass = cheats.password 'reset'

function love.keypressed(key)
	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if (key == 'escape' or key == 'p') and not (gamelost or onMenu()) then
		pausemessage = nil --resets pauseText()
		paused = not paused --pauses or unpauses
		mouse.setGrab(not paused) --releases the mouse if paused
	end

	keyspressed[key] = true

	if not gamelost and onGame() then 
		psycho:keypressed(key)
	end
	
	if gamelost and key == 'r' then
		reloadGame()
	end

	if key == 'left' and state == tutorialmenu then
		swypetimer:setAndGo(width, 0)
		state = mainmenu
	elseif key == 'right' and state == mainmenu then
		swypetimer:setAndGo(0, width)
		state = tutorialmenu
	elseif key == 'left' and state == mainmenu then
		swypetimer:setAndGo(0, -width)
		state = achmenu
	elseif key == 'right' and state == achmenu then
		swypetimer:setAndGo(-width, 0)
		state = mainmenu
	end

	if (gamelost or paused) and key == 'b' then
		paused = false
		state = mainmenu

		cheats.devmode = false
		cheats.image.enabled = false
		resetted = false

		alphatimer:setAndGo(0, 255)

		soundmanager.reset()
		timefactor = 1.0
		currentEffect = nil

		playmessage = nil
		playbutton:setText(playText())
		button.bodies['play'] = playbutton
	end

	cheats.processKey(key)
	soundmanager.processKey(key)
	
	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then resetstats() end
	end
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