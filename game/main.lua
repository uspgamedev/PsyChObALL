width, height = love.graphics.getWidth(),love.graphics.getHeight()

require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"
require "list"
require "boss"
require "psychoball"

local socket = require "socket"
local http = require "socket.http"

response = http.request{ url=URL, create=function()
  local req_sock = socket.tcp()
  req_sock:settimeout(5)
  return req_sock
end}

function readstats()
    local file = filesystem.newFile("high")
    if not filesystem.exists("high") then
        file:open('w')
        file:write("0\n0")
        file:close()
    end
    file:open('r')
    local it = file:lines()
    local r = it()
    if not r then r = 0 end
    besttime = 0 + r
    r = it()
    if not r then r = 0 end
    bestmult = 0 + r
end

function writestats()
	if wasdev then return end
	if besttime > totaltime and bestmult > multiplier then return end
    local file = filesystem.newFile("high")
    file:open('w')
    besttime = math.max(besttime, totaltime)
    bestmult = math.max(bestmult, multiplier)
    file:write(besttime .. "\n" .. bestmult)
    file:close()
end

function love.load()
	devmode = false
	invisible = false -- easter eggs
	muted = false
	volume = 100

	for k,v in pairs(love) do
		if type(v) == 'table' and not _G[k] then
			_G[k] = v
		end
	end

    screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end

	logo = graphics.newImage('resources/LogoBeta.png')
	graphics.setIcon(graphics.newImage('resources/IconBeta.png'))

	v = 220
    version = '0.8.1\n'
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

	reload() -- reload()-> things that should be resetted when player dies, the rest-> one time only
	
	sqrt2 = math.sqrt(2)
	fonts = {}
	
	firsttime = true
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
	
	ultrablastmax = 42 -- maximum number of shots on ultrablast
	ultratimer = timer:new {
		timelimit  = .1,
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

	paintables[1] = circleEffect.bodies
	paintables[2] = shot.bodies
	paintables[3] = enemy.bodies
	paintables[4] = effect.bodies
	
	enemylist = list:new{}

	enemylist:push(enemy:new{})

	enemyaddtimer = timer:new {
		timelimit = 1
	}

	function enemyaddtimer:funcToCall() --adds the enemies to a list
        if not self.first then self.first = true self.timelimit = 2 end
		self.timelimit = .3 + (self.timelimit - .3) / 1.09
		enemylist:push(enemy:new{})
	end


	enemyreleasetimer = timer:new {
		timelimit = 0
	}

	function enemyreleasetimer:funcToCall() --actually releases the enemies on screen
		if not self.first then self.first = true self.timelimit = 2 return end
		self.timelimit = .3 + (self.timelimit - .3) / 1.09
		table.insert(enemy.bodies,enemylist:pop())
	end
	
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

	theboss = boss:new{}

	
	totaltime = 0
	
	timefactor = 1.0
	
	score = 200

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil

	keyspressed = {}
	auxspeed = vector:new {}

	wasdev = devmode
end

function getFont(size)
	if fonts[size] then return fonts[size] end
	fonts[size] = graphics.newFont(size)
	return fonts[size]
end

local moarLSDchance = 4

function lostgame()
    writestats()
    songfadeout:start()

	if deathText() == "The LSD wears off" then
	    song:setPitch(.8)
	    deathtexts[11] = "MOAR LSD"
		for i = 1, moarLSDchance do table.insert(deathtexts, "MOAR LSD") end
		currentEffect = noLSDeffect
	elseif deathText() == "MOAR LSD" then
	    song:setPitch(1)
	    deathtexts[11] = "The LSD wears off"
	    for i = 1, moarLSDchance do table.remove(deathtexts) end
		currentEffect = nil
	end

    gamelost   = true
    timefactor = .05

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
	color[1], color[2], color[3] = gray, gray, gray
	return color
end

function applyeffect( color )
	return currentEffect and currentEffect(color) or color
end

function colorwheel(color, x, xt, alpha)
	xt = xt or colortimer.timelimit
	x = x % xt
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
	graphics.setColor(color(linecolor, colortimer.time + 12, nil, 60))
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

    for i, v in pairs(paintables) do
        for j, m in pairs(v) do
			m:draw()
		end
    end
	theboss:draw()

    graphics.setColor(color(arcsColor, colortimer.time * 1.4))
	graphics.setLine(1)

	for i = enemylist.first, enemylist.last - 1 do
		local a = math.atan((enemylist[i].Vy/ enemylist[i].Vx))
		if enemylist[i].Vx < 0 then a = a + math.pi end
		graphics.arc("line", enemylist[i].x, enemylist[i].y, 30, a - .15, a + .15)
	end
	line()

	
	graphics.setColor(color(maincolor, colortimer.time))
	--painting PsyChObALL
	if not invisible then -- Invisible easter-egg
		psycho:draw()
	end
	
    graphics.print(string.format("Score: %.0f",score), 25, 22)
    graphics.print(string.format("Time: %.1fs",totaltime), 25, 68)
	graphics.print(srt, 27, 96)
	graphics.print("FPS: " .. love.timer.getFPS(), 990, 21)
	graphics.print(string.format("Best Time: %.1fs", math.max(besttime, totaltime)), 25, 46)
	graphics.print(string.format("Best Mult: x%.1f", math.max(bestmult, multiplier)), 965, 83)
	graphics.setFont(getFont(40))
	graphics.print(string.format("x%.1f", multiplier), 950, 35)
	graphics.setFont(getFont(12))
	if devmode then graphics.print("dev Mode on!", 444, 5) end
	graphics.setColor(color(maincolor, colortimer.time, nil, 70))
	graphics.drawq(soundimage, soundquads[soundquadindex], 1030, 675)

	if invisible then
		graphics.print("Invisible mode ON!", 432, 18)
	end
	
	if firsttime then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
		graphics.setFont(getFont(20))
		graphics.print("You get points when:", 270, 36)
		graphics.print("You kill an enemy", 303, 72)
		graphics.print("You lose points when:", 607, 36)
		graphics.print("You miss a shot", 641, 72)
		graphics.print("You let an enemy escape", 641, 95)
		graphics.setFont(getFont(30))
		graphics.print("Game Ends when your score hits zero", 135, 534)
		graphics.setFont(getFont(20))
		graphics.print("Use WASD or arrows to move", 202, 300)
		graphics.print("Click to shoot", 560, 390)
		graphics.print("Hold space to charge:", 540, 432)
		graphics.print("click to continue", 870, 645)
		graphics.setFont(getFont(25))
		graphics.print("Or when you get hit.", 670, 570)
		graphics.setFont(getFont(12))
		graphics.print("v" .. version, 513, 687)
		if latest ~= version then
			graphics.print("Version " .. latest, 422, 700)
			graphics.print("is available to download!", 510, 700)
		end
		graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)
		graphics.setFont(getFont(35))
		graphics.setColor(color(ultrablastcolor, colortimer.time * 0.856))
		graphics.print("ulTrAbLaST", 762, 420)

		graphics.setColor(color(logocolor, colortimer.time * 4.5 + .54))
		graphics.draw(logo, 120, 105, nil, 0.25, 0.20)
		graphics.setFont(getFont(12))
	end

	if gamelost then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
		if wasdev then
			graphics.print("Your scores didn't count, cheater!", 182, 215)
		elseif besttime == totaltime then
			graphics.setFont(getFont(60))
			graphics.print("You beat the best time!", 160, 100)
		end
		graphics.setFont(getFont(40))
		graphics.print(deathText(), 270, 300)
		graphics.setFont(getFont(30))
		graphics.print(string.format("You lasted %.1fsecs", totaltime), 486, 550)
		if score ~= 0 then graphics.print("You were hit.", 132, 180) end
		if score == 0 then graphics.print("Your score hit 0.", 132, 180) end
		graphics.setFont(getFont(22))
		graphics.print("'r' to retry", 540, 480)
		graphics.setFont(getFont(12))
	end
	if esc then
		graphics.setColor(color(otherstuffcolor, colortimer.time - colortimer.timelimit / 2))
		graphics.setFont(getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(getFont(12))
	end
end

deathtexts = {"Game Over", "No one will\n miss you","You now lay\n   with the dead","Yo momma so fat\n   you died",
"You ceased to exist","Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?",
"All your base\n are belong to BALLS","You wake up and\n realize it was all a nightmare","The LSD wears off",
"MIND BLOWN","Just one more","USPGameDev Rulez","A winner is not you","Have a nice death","There is no cake\n   also you died","You have died of\n  dysentery"}

function deathText()
	dtn = dtn or deathtexts[math.random(table.getn(deathtexts))]
	return dtn
end

function love.update(dt)	
	isPaused = (esc or pause or firsttime) 
	if not gamelost and score <= 0 then score = 0 psycho.diereason = "score" lostgame() end
	
	
	timer.updatetimers(dt, timefactor, isPaused, gamelost)
	
	dt = dt * timefactor
	
	if isPaused then return end
	if not gamelost then totaltime = totaltime + dt end

    theboss:update(dt)
    psycho:update(dt)

    local todelete = {}
    for i, v in pairs(paintables) do
        for j, m in pairs(v) do
			if not m:update(dt) then
				table.insert(todelete, j) --deletes items that return false
			end
		end
		local a = 0
		for k, n in ipairs(todelete) do
			if type(n) == 'number' then
				v[n - a]:handleDelete()
				table.remove(v, n - a)
				a = a + 1
			else
				v[n]:handleDelete()
				v[n] = nil
			end
		end
		todelete = nil
		todelete = {}
    end
	todelete = nil
end

function love.mousepressed(x, y, button)
    if esc or pause then return end
    if firsttime then firsttime = false return end
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

function love.keypressed(key)
	--checking for dev code
	if devmode then
		devmode = devpass(key)
		if not devmode then 
			v = 220
		end
	else 
		devmode = devpass(key)
		if devmode then wasdev = true return end
	end
	--

	if (key == 'escape' or key == 'p') and not (gamelost or firsttime) then esc = not esc end

	keyspressed[key] = true

	if not gamelost then 
		auxspeed:add(
			((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v or 0) 
				+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v or 0),
			((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v or 0) 
				+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v or 0)
		)
		psycho.speed:set(auxspeed)

		if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
			psycho.speed:div(sqrt2)
		end

		if key == ' ' and not isPaused then
			ultrablast = 10
			psycho.ultrameter = circleEffect:new {
				based_on   = psycho,
				sizeGrowth = 30,
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

	if devmode then
		if not paused and key == 'k' then lostgame() end
		if key == '0' then multiplier = multiplier + 2
		elseif key == '9' then multiplier = multiplier - 2
		elseif key == '8' then addscore(100)
		elseif key == '7' then addscore(-100)
		elseif key == '6' then v = v + 10
		elseif key == '5' then v = v - 10 end
	end

	invisible = invisiblepass(key)
end

function do_ultrablast()
	for i=1, ultrablast do
		shoot(psycho.x + (math.cos(math.pi * 2 * i / ultrablast) * 100), psycho.y + (math.sin(math.pi * 2 * i / ultrablast) * 100))
	end
end

function love.keyreleased(key, code)
	if not keyspressed[key] then return
	else keyspressed[key] = false end

	if not gamelost then
	    auxspeed:sub(
			((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v or 0) 
				+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v or 0),
			((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v or 0) 
				+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v or 0)
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
    pause = not f
end