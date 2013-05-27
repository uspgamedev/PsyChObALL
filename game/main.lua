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

function writestats()
	if wasdev then return end
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
	besttime  = 0
	bestmult  = 0
	bestscore = 0
	filemanager.writetable({
		besttime  = besttime,
		bestmult  = bestmult,
		bestscore = bestscore
	}, "stats")
end

function love.load()
	state = 0
	mainmenu = 0 -- mainmenu
	tutorialmenu = 1
	achmenu  = 2 -- Tela de achievements
	survivor = 10 -- modo de jogo survivor
	resetted = false
	devmode = false
	invisible = false -- easter eggs
	imagecheat = false
	muted = false
	volume = 100

	for k,v in pairs(love) do
		if type(v) == 'table' and not _G[k] then
			_G[k] = v
		end
	end

	pizzaimage = graphics.newImage("resources/pizza.png")
	yanimage = graphics.newImage("resources/yan.png")
	ricaimage = graphics.newImage("resources/rica.png")
	rikaimage = graphics.newImage("resources/rika.png")
	imageoverride = nil --image to be painted instead of circles

	screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end

	logo = graphics.newImage('resources/LogoBeta.png')
	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))

	v = 240
	version = '0.9.0\n'
	latest = http.request("http://uspgamedev.org/downloads/projects/psychoball/latest") or version

	song = audio.newSource("resources/Phantom - Psychodelic.ogg")
	song:play()
	song:setLooping(true)
	songsetpoints = {20,123,180,308,340}
	songfadeout = timer:new{
		timelimit 	 = .01,
	 	running 	 = false,
	 	pausable 	 = false,
	 	timeaffected = false,
	 	persistent 	 = true
	}

	function songfadeout:funcToCall() -- song fades out
		if muted then return end
		if song:getVolume() <= (.02 * volume / 100) then 
			song:setVolume(0) 
			self:stop()
		else song:setVolume(song:getVolume() - .02) end
	end

	songfadein = timer:new{
		timelimit 	 = .03,
		running 	 = false,
		pausable 	 = false,
		timeaffected = false,
		persistent 	 = true
	}

	function songfadein:funcToCall() -- song fades in
		if muted or gamelost then return end
		if song:getVolume() >= (.98 * volume / 100) then 
			song:setVolume(volume / 100)
			self:stop()
		else song:setVolume((song:getVolume() + .02)) end
	end

	colortimer = timer:new{
		timelimit  = 10,
		pausable   = false,
		persistent = true
	}

	wasdev = false

	reload() -- reload()-> things that should be resetted when player dies, the rest-> one time only
	mouse.setGrab(false)
	
	sqrt2 = math.sqrt(2)
	fonts = {}
	coolfonts = {}
	
	readstats()	
	
	multtimer = timer:new {
		timelimit  = 2.2,
		running    = false,
		onceonly   = true,
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
		running    = false,
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
		running    = false,
		onceonly   = true,
		persistent = true,
		works_on_gamelost = false
	}

	function inverttimer:funcToCall() -- disinverts the screen color
		if currentEffect ~= noLSDeffect then 
			song:setPitch(1)
			timefactor = 1.0
			currentEffect = nil
		end
	end

	function inverttimer:handlereset()
		self:stop()
		self:funcToCall()
	end

	swypetimer = vartimer:new {
		running = false,
		var = 0,
		speed = 3000
	}

	alphatimer = vartimer:new {
		running = false,
		var = 255,
		speed = 300
	}

	--sound images
	soundimage = graphics.newImage("resources/SoundIcons.png")
	soundquads = {
		graphics.newQuad(200, 0, 40, 40, 300, 40),
		graphics.newQuad(160, 0, 40, 40, 300, 40),
		graphics.newQuad(120, 0, 40, 40, 300, 40),
		graphics.newQuad(80,  0, 40, 40, 300, 40),
		graphics.newQuad(40,  0, 40, 40, 300, 40),
		graphics.newQuad(0,   0, 40, 40, 300, 40),
		graphics.newQuad(240, 0, 40, 40, 300, 40)
	}
	soundquadindex = 6
end

function reload()
	ultracounter = 3

	timer.closenonessential()
	
	song:seek(songsetpoints[math.random(#songsetpoints)])
	song:setVolume(0)

	if not muted then songfadein:start() end
	
	psycho = psychoball:new{
		position = psycho and psycho.position or vector:new{513,360}
	}
	
	paintables = {}
	shot.bodies = {}
	effect.bodies = {}
	circleEffect.bodies = {}
	enemy.bodies = {}
	bosses.bodies = {}

	paintables[1] = circleEffect.bodies
	paintables[2] = shot.bodies
	paintables[3] = enemy.bodies
	paintables[4] = effect.bodies
	paintables[5] = bosses.bodies
	
	enemylist = list:new{}

	enemylist:push(enemy:new{})

	enemyaddtimer = timer:new {
		timelimit = 2
	}

	function enemyaddtimer:funcToCall() --adds the enemies to a list
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		enemylist:push(enemy:new{})
	end

	enemyaddtimer:start(2)

	enemyreleasetimer = timer:new {
		timelimit = 2
	}

	function enemyreleasetimer:funcToCall() --actually releases the enemies on screen
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		table.insert(enemy.bodies,enemylist:pop())
	end

	enemyreleasetimer:start(1.5)
	
	shottimer = timer:new{
		timelimit = .18,
		running   = false
	}

	function shottimer:funcToCall() -- continues shooting when you hold the mouse
		shoot(mouse.getPosition()) 
	end
	
	multiplier = 1
	
	
	circletimer = timer:new{
		timelimit = .2
	}

	function circletimer:funcToCall() -- releases cirleEffects
		if not gamelost then
			circleEffect:new {
				based_on = psycho
			}
		end
		for i,v in pairs(enemy.bodies) do
			if v.size == 15 and math.random(2) == 1 --[[reducing chance]] then 
				circleEffect:new{
					based_on = v
				} 
			end
		end
	end

	superballtimer = timer:new {
		timelimit = 20,
		running = false,
		works_on_gamelost = false
	}

	local possiblePositions = {vector:new{30, 30}, vector:new{width - 30, 30}, vector:new{width - 30, height - 30}, vector:new{30, height - 30}}
	function superballtimer:funcToCall()
		if #bosses.bodies ~= 0 then self.timelimit = 2 end
		bosses.newsuperball{ position = possiblePositions[math.random(4)]:clone() }
		self.timelimit = 20
	end

	superballtimer:start(5)

	totaltime = 0
	blastime = 0

	timefactor = 1.0

	score = 0
	blastscore = 0 --Variavel que da ultrablast points por pontos

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil

	keyspressed = {}
	auxspeed = vector:new {}

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
	-- body
end
local moarLSDchance = 4

function lostgame()
	if gamelost then return end
	writestats()
	songfadeout:start()
	mouse.setGrab(false)

	if deathText() == "Supreme." then dtn = nil end --make it much rarer

	if deathText() == "The LSD wears off" then
		song:setPitch(.8)
		deathtexts[1] = "MOAR LSD"
		for i = 1, moarLSDchance do table.insert(deathtexts, "MOAR LSD") end
		currentEffect = noLSDeffect
	elseif deathText() == "MOAR LSD" then
		song:setPitch(1)
		deathtexts[1] = "The LSD wears off"
		for i = 1, moarLSDchance do table.remove(deathtexts) end
		currentEffect = nil
	end

	gamelost   = true
	timefactor = .05
	pst = nil

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
		r = 100 			   -- 100%
		g = 100 * x / (xt / 3) -- 0->100%
		b = 0 				   -- 0%
	elseif x <= xt / 2 then
		r = 100 * (1 - ((x - xt / 3) / (xt / 2 - xt / 3))) -- 100->0%
		g = 100 - 20 * ((x - xt / 3) / (xt / 2 - xt / 3))  -- 100->80%
		b = 0 								 			   -- 0%
	elseif x <= 7 * xt / 12 then
		r = 0 								  				  -- 0%
		g = 80 - 20 * ((x - xt / 2) / (7 * xt / 12 - xt / 2)) -- 80->60%
		b = 60 * ((x - xt / 2) / (7 * xt / 12 - xt / 2)) 	  -- 0->60%
	elseif x <= 255 * xt/360 then
		r = 11 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) 	   -- 0->11%
		g = 60 - 49 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->11%
		b = 60 + 10 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->70%
	elseif x<=318*xt/360 then
		r = 11 + 59 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 11->70%
		g = 11 * (1 - ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))) -- 11->0%
		b = 70 - 10 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 70->60%
	else
		r = 70 + 30 * ((x - 318 * xt / 360) / (xt - 318 * xt / 360))  -- 70->100%
		g = 0 										  				  -- 0%
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

	if state == survivor then
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
	if not invisible and state == survivor then -- Invisible easter-egg
		psycho:draw()
	end
	graphics.setColor(color(maincolor, colortimer.time))


	graphics.print(string.format("FPS:%.0f", love.timer.getFPS()), 1000, 10)
	if state == survivor then
		graphics.setFont(getCoolFont(22))
		graphics.print(string.format("%.0f", score), 68, 20)
		graphics.print(string.format("%.1fs", totaltime), 68, 42)
		graphics.setFont(getFont(12))
		graphics.print("Score:", 25, 24)
		graphics.print("Time:", 25, 48)
		graphics.print(srt, 27, 96)
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
		if devmode then graphics.print("dev mode on!", 446, 5) end
		if invisible then graphics.print("Invisible mode on!", 432, 18) end
		if imagecheat then
			if imageoverride == yanimage then graphics.print("David Robert Jones mode on!", 395, 32)
			elseif imageoverride == pizzaimage then graphics.print("Italian mode on!", 438, 32) 
			elseif imageoverride == ricaimage then graphics.print("Richard mode on!", 433, 32)
			elseif imageoverride == rikaimage then graphics.print("Detective mode on!", 428, 32) end
		end
	end
	graphics.setColor(color(maincolor, colortimer.time, 70))
	graphics.drawq(soundimage, soundquads[soundquadindex], 1030, 675)
	

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
	

	if gamelost and state == survivor then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
		if wasdev then
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

	if esc and state == survivor then
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
"YOU WIN!!! \n                       nope, chuck testa","Supreme."}

function deathText()
	dtn = dtn or deathtexts[math.random(#deathtexts)]
	return dtn
end

function pauseText()
	pst = pst or pausetexts[math.random(#pausetexts)]
	return pst
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
    if button == 'l' and not gamelost then
      shoot(x, y)
		shottimer:start()
    end
end

function love.mousereleased(x, y, button)
	if button == 'l' then
		shottimer:stop()
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

function password( pass )
	local progress = 0
	return function ( key )
		if key == pass[progress + 1] then
			progress = progress + 1
			if progress == #pass then
				progress = 0
				return true
			end
		else
			progress = 0
			return false
		end
	end
end

function passwordtoggle( pass )
	local toggle = false
	local check = password(pass)
	return function ( key )
		if check(key) then toggle = not toggle end
		return toggle
	end
end

local devpass = passwordtoggle {'p','s','y','c','h','o'}
local invisiblepass = passwordtoggle {'g', 'h', 'o', 's', 't'}
local pizzapass = password {'p', 'i', 'z', 'z', 'a'}
local yanpass = password {'y', 'a', 'n'}
local ricapass = password {'r', 'i', 'c','a'}
local rikapass = password {'r', 'i', 'k','a'}
local resetpass = password {'r','e','s','e','t'}

function love.keypressed(key)
	--checking for dev code
	if state == survivor then
		if devmode then
			devmode = devpass(key)
		else 
			devmode = devpass(key)
			if devmode then wasdev = true return end
		end
	end

	if (key == 'escape' or key == 'p') and not (gamelost or onMenu()) then
		pst = nil
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


		devmode = false
		imagecheat = false
		invisible = false
		resetted = false

		alphatimer:setAndGo(0, 255)
		if muted then
			song:setVolume(0)
   		else
			song:setVolume(volume / 100)
		end
		song:setPitch(1.0)
		timefactor = 1.0
		currentEffect = nil
	end
	
	if key == 'm' then
		if muted then
			if not gamelost then song:setVolume(volume / 100) end
			muted = false
			soundquadindex = volume/20 + 1
		else
			song:setVolume(0)
			muted = true
			soundquadindex = 7
		end
	end
	
	if key == '.' and not muted and volume < 100 then
		volume = volume + 20
		soundquadindex = volume/20 + 1
		if not gamelost then
			song:setVolume(volume / 100)
		end
	elseif key == ',' and muted == false and volume > 0 then
		volume = volume - 20
		soundquadindex = volume/20 + 1
		if not gamelost and not songfadein.running then
			song:setVolume(volume / 100)
		end
	end


	if devmode and state == survivor then
		if not esc and key == 'k' then lostgame() end
		if key == '0' then multiplier = multiplier + 2
		elseif key == '9' then multiplier = multiplier - 2
		elseif key == '8' then addscore(100)
		elseif key == '7' then addscore(-100)
		elseif key == '6' then v = v + 10
		elseif key == '5' then v = v - 10
		elseif key == '4' then timefactor = timefactor * 1.1
		elseif key == '3' then timefactor = timefactor * 0.9
		elseif key == 'l' then dtn = deathtexts[1] lostgame()
		elseif key == 'u' then love.update(10) --skips 10 seconds
		end
	end
	
	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then resetstats() end
	end


	if state == survivor then
		
		invisible = invisiblepass(key)
		
		if pizzapass(key) then
			if not imagecheat then imagecheat = true end
			if imageoverride == pizzaimage then imagecheat = false end
			if imagecheat then imageoverride = pizzaimage end
		end
		
		if yanpass(key) then
			if not imagecheat then imagecheat = true end
			if imageoverride == yanimage then imagecheat = false end
			imagecheatwithalpha = true
			if imagecheat then imageoverride = yanimage end
		end

		if ricapass(key) then
			if not imagecheat then imagecheat = true end
			if imageoverride == ricaimage then imagecheat = false end
			imagecheatwithalpha = true
			if imagecheat then imageoverride = ricaimage end
		end

		if rikapass(key) then
			if not imagecheat then imagecheat = true end
			if imageoverride == rikaimage then imagecheat = false end
			imagecheatwithalpha = true
			if imagecheat then imageoverride = rikaimage end
		end
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

	if not gamelost and state == survivor then
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