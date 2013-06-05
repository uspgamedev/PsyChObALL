width, height = 1080, 720

require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"
require "vartimer"
require "list"
require "bosses"
require "psychoball"
require "filemanager"
require "soundmanager"
require "cheats"

local socket = require "socket"
local http = require "socket.http"

response = http.request{ url=URL, create=function()
	local req_sock = socket.tcp()
	req_sock:settimeout(3)
	return req_sock
end}

function readstats()
	local stats = filemanager.readtable "stats"

	besttime  = stats.besttime  or 0
	bestmult  = stats.bestmult  or 0
	bestscore = stats.bestscore or 0
end

--[[function readachievements()
	local achievements = filemanager.readtable "achievements"

	twentymult  = achievements.twentymult or false
end

function writeachievements()
	filemanager.writetable({
		twentymult  = twentymult
	}, "achievements")
end]]

function writestats()
	if cheats.wasdev then return end
	if besttime > totaltime and bestmult > multiplier and bestscore > score then return end
	besttime  = math.max(besttime, totaltime)
	bestmult  = math.max(bestmult, multiplier)
	bestscore = math.max(bestscore, score)
	filemanager.writetable({
		besttime  = besttime,
		bestmult  = bestmult,
		bestscore = bestscore
	}, "stats")
end

function resetstats()
	besttime, bestmult, bestscore  = 0, 0, 0
	filemanager.writetable({
		besttime  = 0,
		bestmult  = 0,
		bestscore = 0
	}, "stats")
end

function readconfig()
	local config = filemanager.readtable "config"

	soundmanager.volume = config.volume or 100
	soundmanager.muted  = config.muted == true

	if version ~= config.version then
		--handle something maybe
	end
end

function writeconfig()
	filemanager.writetable({
		volume =	 soundmanager.volume,
		muted =	 soundmanager.muted,
		version = version
		}, "config")
end


function love.load()
	initBase()
	initGameVars()

	--reload() -- reload()-> things that should be resetted when player dies
	mouse.setGrab(false)
	
end

function initBase()
	-- [["Localizing" Love2D tables]]
	for k,v in pairs(love) do
		if type(v) == 'table' and not _G[k] then
			_G[k] = v
		end
	end
	-- [[End of"Localizing" Love2D tables]]

	-- [[Initing Variables]]
	v = 240 --main velocity of everything
	state = 0
	mainmenu = 0 -- mainmenu
	tutorialmenu = 1
	achmenu  = 2 -- Tela de achievements
	survivor = 10 -- modo de jogo survivor
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
	-- [[End of Initing Variables]]
	
	-- [[Reading Files]]
	readconfig()
	readstats()
	-- [[end of Reading Files]]
	
	-- [[Loading Resources]]
	logo = graphics.newImage('resources/LogoBeta.png')

	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))
	version = '0.9.0\n'
	latest = http.request("http://uspgamedev.org/downloads/projects/psychoball/latest") or version
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
	
	ultrablastmax = 84 -- maximum number of shots on ultrablast
	ultratimer = timer:new {
		timelimit  = .02,
		persistent = true
	}

	function ultratimer:funcToCall() -- adds more shots to ultrablast
		if ultrablast < ultrablastmax then
			ultrablast = ultrablast + 1
		end
		if ultrablast == ultrablastmax - 1 then
			psycho.ultrameter.sizeGrowth = 0
		end
	end

	function ultratimer:handlereset()
		self:stop()
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
	psycho = psychoball:new{
		position = psycho and psycho.position or vector:new{513,360}
	}
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
	
	timefactor = 1.0
	multiplier = 1
	totaltime = 0
	blastime = 0
	score = 0
	blastscore = 0 --Variavel que da ultrablast points por pontos

	pause = false
	gamelost = false
	esc = false

	deathmessage = nil
end

function cleartable( t )
	for k in pairs(t) do t[k] = nil end
end

function reload()
	resetVars()
	timer.closenonessential()
	
	enemylist:push(enemy:new{})

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
	writestats()
	soundmanager.fadeout()
	mouse.setGrab(false)

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

	psycho.speed:set(0,0)
	if psycho.ultrameter then psycho.ultrameter.sizeGrowth = -300 end
	neweffects(psycho,80)
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

function sign(x)
    return x == 0 and 0 or x < 0 and -1 or 1 
end

local linecolor = {0,0,0,0}
local mousecirclecolor = {0,0,0,0}

function line()
	if gamelost then return end

	graphics.setColor(color(mousecirclecolor, colortimer.time + 12))
	graphics.circle("line", mouse.getX(), mouse.getY(), 5)
	graphics.setColor(color(linecolor, colortimer.time + 12, 60))
	local m = (mouse.getY() - psycho.y)/(mouse.getX() - psycho.x)
	local x,y
	if (mouse.getX() - psycho.x) > 0 then 
		x = graphics.getWidth()
		y = psycho.y + (x - psycho.x) * m
	else
		x = 0
		y = psycho.y + (x - psycho.x) * m
	end
	graphics.line(psycho.x, psycho.y, x, y)
end

local maincolor = {0,0,0,0}
local backColor = {0,0,0,0}
local arcsColor = {0,0,0,0}
local otherstuffcolor = {0,0,0,0}
local ultrablastcolor = {0,0,0,0}
local logocolor = {0,0,0,0}

function love.draw()
	graphics.translate(width/2, height/2)
	graphics.rotate(angle.var)
	graphics.translate(-width/2, -height/2)
	graphics.setLine(4)
	graphics.setFont(getFont(12))

	colorwheel(backColor, colortimer.time + 17 * colortimer.timelimit / 13)
	backColor[1] = backColor[1] / 2
	backColor[2] = backColor[2] / 2
	backColor[3] = backColor[3] / 2
	applyeffect(backColor)
	backColor[1] = backColor[1] / 4
	backColor[2] = backColor[2] / 4
	backColor[3] = backColor[3] / 4
	graphics.setColor(backColor)
	graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight()) --background color

	if onGame() then
		for i, v in pairs(paintables) do
			for j, m in pairs(v) do
				m:draw()
			end
		end

		graphics.setColor(color(arcsColor, colortimer.time * 1.4))
		graphics.setLine(1)

		for i = enemylist.first, enemylist.last - 1 do
			local a = math.atan((enemylist[i].Vy/ enemylist[i].Vx))
			if enemylist[i].Vx < 0 then a = a + math.pi end
			graphics.arc("line", enemylist[i].x, enemylist[i].y, 30, a - .15, a + .15)
		end
		line()
	end

	
	--painting PsyChObALL
	if not cheats.invisible and onGame() then -- Invisible easter-egg
		psycho:draw()
	end
	graphics.setColor(color(maincolor, colortimer.time))


	graphics.print(string.format("FPS:%.0f", love.timer.getFPS()), 1000, 10)
	if onGame() then
		graphics.setFont(getCoolFont(22))
		graphics.print(string.format("%.0f", score), 68, 20)
		graphics.print(string.format("%.1fs", totaltime), 68, 42)
		graphics.setFont(getFont(12))
		graphics.print("Score:", 25, 24)
		graphics.print("Time:", 25, 48)
		graphics.print(string.format("Best Score: %0.f",   math.max(bestscore, score)), 25, 68)
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
	graphics.setColor(color(maincolor, colortimer.time, 70))
	soundmanager.drawSoundIcon(1030, 675)
	

	graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))

	if alphatimer.var > 0 then
		graphics.push()
		graphics.translate(math.floor(-swypetimer.var), 0)
		--mainmenu
		graphics.setFont(getFont(12))
		graphics.setColor(color(ultrablastcolor, colortimer.time * 0.856, alphatimer.var))
		graphics.print("v" .. version, 513, 687)
		graphics.print('Write "reset" to delete stats' , 15, 10)
		if resetted then graphics.print("~~stats deleted~~", 25, 23) end


		if latest ~= version then
			graphics.print("Version " .. latest, 422, 700)
			graphics.print("is available to download!", 510, 700)
		end
		graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)

		graphics.setColor(color(logocolor, colortimer.time * 4.5 + .54, alphatimer.var))
		graphics.draw(logo, 120, 75, nil, 0.25, 0.20)
		graphics.setFont(getFont(12))

		graphics.translate(width, 0)
		--tutorialmenu
		graphics.setColor(color(logocolor, colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("CONTROLS", 380, 36)
		graphics.setFont(getCoolFont(40))
		graphics.print("Survivor Mode:", 170, 350)
		graphics.setColor(color(logocolor, colortimer.time * 2.5 + .54))
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
		graphics.setColor(color(ultrablastcolor, colortimer.time * 0.856))
		graphics.print("ulTrAbLaST", 290, 242)
		graphics.setColor(color(logocolor, colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 10)
		graphics.circle("fill", 520, 450, 10)
		graphics.circle("fill", 160, 510, 10)
		graphics.circle("fill", 520, 240, 10)
		graphics.circle("fill", 520, 280, 10)
		graphics.setColor(color(logocolor, colortimer.time * 7.5 + .54))
		graphics.circle("fill", 520, 180, 10)
		graphics.circle("fill", 130, 450, 10)
		graphics.circle("fill", 50, 263, 10)
		
		graphics.translate(-2 * width, 0)
		--achmenu
		graphics.setColor(color(logocolor, colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("ACHIEVEMENTS", 340, 36)
		graphics.setColor(color(logocolor, colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 5)
		graphics.setColor(color(logocolor, colortimer.time * 7.5 + .54))
		graphics.circle("fill", 130, 210, 5)
		graphics.setFont(getCoolFont(18))
		graphics.print("Click or press the right arrow key to go back", 670, 645)

		graphics.pop()
	end
	

	if gamelost and onGame() then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
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
		graphics.setFont(getFont(12))
	end

	if esc and onGame() then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
		graphics.setFont(getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(getCoolFont(20))
		graphics.print("Press b", 603, 550)
		graphics.print(pauseText(), 682, 550)
		graphics.setFont(getFont(12))
	end
end

pausetexts = {"to surrender","to go back","to give up","to admit defeat","to /ff", "to RAGE QUIT","if you can't handle the balls"}

deathtexts = {"The LSD wears off", "Game Over", "No one will\n      miss you", "You now lay\n   with the dead", "Yo momma so fat\n   you died",
"You ceased to exist", "Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?", "All your base\n     are belong to BALLS",
"You wake up and\n     realize it was all a nightmare", "MIND BLOWN","Just one more","USPGameDev Rulez","A winner is not you","Have a nice death",
"There is no cake\n   also you died","You have died of\n      dysentery","You failed", "Epic fail", "BAD END",
"YOU WIN!!! \n                       nope, chuck testa","Supreme.","Embrace your defeat","Balls have no mercy","You have no balls left","Nevermore...",
"Rest in Peace","Die in shame","You've found your end"}

function deathText()
	deathmessage = deathmessage or deathtexts[math.random(#deathtexts)]
	return deathmessage
end

function pauseText()
	pausemessage = pausemessage or pausetexts[math.random(#pausetexts)]
	return pausemessage
end

local todelete = {}

function love.update(dt)
	isPaused = (esc or onMenu())

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

function love.mousepressed(x, y, button)
	if esc or pause then return end
	if button == 'l' and state == mainmenu then
		state = survivor
		alphatimer:setAndGo(255, 0)
		mouse.setGrab(true)
		reload() return
	end
	if button == 'r' and state == mainmenu then
		swypetimer:setAndGo(0, width)
		state = tutorialmenu
		return
	end
	if (button == 'l' or button == 'r') and state == tutorialmenu then
		swypetimer:setAndGo(width, 0)
		state = mainmenu
		return
	end
	if (button == 'l' or button == 'r') and state == achmenu then
		swypetimer:setAndGo(-width, 0)
		state = mainmenu
		return
	end
	if button == 'l' and onGame() then
		shoot(x, y)
		shot.timer:start()
	end
end

function love.mousereleased(x, y, button)
	if button == 'l' and onGame() then
		shot.timer:stop()
	end
end

function shoot(x, y)
	local diffx = x - psycho.x
	local diffy = y - psycho.y
	local Vx = signum(diffx) * math.sqrt((9 * v^2 * diffx^2) / (diffx^2 + diffy^2))
	local Vy = signum(diffy) * math.sqrt((9 * v^2 * diffy^2) / (diffx^2 + diffy^2))
	table.insert(shot.bodies, shot:new {
		position = psycho.position:clone(),
		speed	 = vector:new {Vx, Vy}
		})
end

function signum(a)
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
	if (key == 'escape' or key == 'p') and not (gamelost or onMenu()) then
		pausemessage = nil
		esc = not esc
		mouse.setGrab(not esc)
	end

	keyspressed[key] = true

	if not gamelost and state == survivor then 
		auxspeed:add(
			((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v*1.3 or 0) 
				+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v*1.3 or 0),
			((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v*1.3 or 0) 
				+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v*1.3 or 0)
		)
		psycho.speed:set(auxspeed)

		if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
			psycho.speed:div(sqrt2)
		end

		if key == ' ' and not isPaused and state == survivor and ultracounter > 0 then
			ultracounter = ultracounter - 1
			ultrablast = 10
			psycho.ultrameter = circleEffect:new {
				based_on   = psycho,
				sizeGrowth = 25,
				alpha 	   = 100,
				linewidth  = 6,
				index 	   = 'ultrameter'
			}
			psycho.ultrameter.position = psycho.position
			ultratimer:start()
		end
	end
	
	if gamelost and key == 'r' then
		reload()
	end

	if key == 'left' and state == tutorialmenu then
		swypetimer:setAndGo(width, 0)
		state = mainmenu
		return
	end

	if key == 'right' and state == mainmenu then
		swypetimer:setAndGo(0, width)
		state = tutorialmenu
		return
	end

	if key == 'left' and state == mainmenu then
		swypetimer:setAndGo(0, -width)
		state = achmenu
		return
	end

	if key == 'right' and state == achmenu then
		swypetimer:setAndGo(-width, 0)
		state = mainmenu
		return
	end

	if keyspressed['lalt'] and keyspressed['f4'] then event.push('quit') end

	if (gamelost or esc) and key == 'b' then
		esc = false
		state = mainmenu


		cheats.devmode = false
		cheats.image.enabled = false
		resetted = false

		alphatimer:setAndGo(0, 255)

		soundmanager.reset()
		timefactor = 1.0
		currentEffect = nil
	end

	cheats.handleKey(key)
	soundmanager.handleKey(key)
	
	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then resetstats() end
	end
end

function do_ultrablast()
	for i=1, ultrablast do
		shoot(psycho.x + (math.cos(math.pi * 2 * i / ultrablast) * 100), psycho.y + (math.sin(math.pi * 2 * i / ultrablast) * 100))
	end
end

function love.keyreleased(key, code)
	if not keyspressed[key] then return
	else keyspressed[key] = false end

	if not gamelost and onGame() then
		auxspeed:sub(
			((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v * 1.3 or 0) 
				+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v * 1.3 or 0),
			((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v * 1.3 or 0) 
				+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v * 1.3 or 0)
		)
		psycho.speed:set(auxspeed)

		if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
			psycho.speed:div(sqrt2)
		end

		if key == ' ' then
			if ultratimer.running then
				ultratimer:stop()
				if psycho.ultrameter then
					psycho.ultrameter.sizeGrowth = -300
				end
				if not isPaused then do_ultrablast() end
			end
		end
	end
	
	if key == 'scrollock' then 
	    graphics.newScreenshot():encode('screenshot_' .. screenshotnumber .. '.png')
	    screenshotnumber = screenshotnumber + 1
	end
end

function love.focus(f)
   if not (f or gamelost or onMenu()) then esc = true end
end

function love.quit()
	writeconfig()
end