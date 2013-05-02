width, height = love.graphics.getWidth(),love.graphics.getHeight()

require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"
require "list"
require "psychoball"

local http = require("socket.http")

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
    if not r then r=0 end
    besttime = 0 + r
    r= it()
    if not r then r=0 end
    bestmult = 0 + r
end

function writestats()
    local file = filesystem.newFile("high")
    file:open('w')
    if totaltime>besttime then besttime = totaltime end
    file:write(besttime .. "\n" .. bestmult)
    file:close()
end

function love.load()
	for k,v in pairs(love) do
		if type(v)== 'table' and not _G[k] then
			_G[k] = v
		end
	end

    screenshotnumber = 1
	while(filesystem.exists('screenshot_' .. screenshotnumber .. '.png')) do screenshotnumber = screenshotnumber + 1 end

	logo = graphics.newImage('resources/LogoBeta.png')

	v = 220
    version = '0.8.1\n'
	latest = http.request("http://uspgamedev.org/downloads/projects/psychoball/latest")
	print(version == latest)

	timer.ts = {}
	filesystem.setIdentity("PsyChObALL")
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
		if song:getVolume()<=.02 then 
        	song:setVolume(0) 
            self:stop()
        else song:setVolume(song:getVolume()-.02) end
	end

	 songfadein = timer:new{
	 	timelimit 	 = .03,
	 	running 	 = false,
	 	pausable 	 = false,
	 	timeaffected = false,
	 	persistent 	 = true
	 }

	 function songfadein:funcToCall() -- song fades in
        if song:getVolume()>=.98 then 
            song:setVolume(1) 
            self:stop()
        else song:setVolume(song:getVolume()+.02) end
	 end

	colortimer = timer:new{
		timelimit  = 10,
		pausable   = false,
		persistent = true
	}

	reload() -- reload()-> things that should be resetted when player dies, the rest-> one time only
	
	sqr2 = math.sqrt(2)
	fonts = {}
	
	firsttime = true
	readstats()	
	
	currentPE = nil
	currentPET = nil
	noLSD_PET = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
    noLSD_PE = graphics.newPixelEffect[[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
	invertPET = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
    invertPE = graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
	
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
     	if currentPE ~= noLSD_PE then 
     		song:setPitch(1)
			timefactor = 1.0
			currentPE = nil
			currentPET = nil 
    	end
    end

    function inverttimer:handlereset()
    	self:stop()
    	self:funcToCall()
    end
end

function reload()
	timer.closenonessential()
	
	song:seek(songsetpoints[math.random(#songsetpoints)])
	song:setVolume(0)
	songfadein:start()
	
	psycho = psychoball:new{
		position = vector:new{513,360}
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
		self.timelimit = .3 + (self.timelimit-.3)/1.09
		enemylist:push(enemy:new{})
	end


	enemyreleasetimer = timer:new {
		timelimit = 0
	}

	function enemyreleasetimer:funcToCall(...) --actually releases the enemies on screen
		if not self.first then self.first = true self.timelimit = 2 return end
		self.timelimit = .3 + (self.timelimit-.3)/1.09
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
			if v.size==15 and math.random(2)==1 --[[reducing chance]] then 
				circleEffect:new{
					based_on = v
				} 
			end
		end
	end
	
	totaltime = 0
	
	timefactor = 1.0
	
	score = 200

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil
end

function getFont(size)
	if fonts[size] then return fonts[size] end
	fonts[size] = graphics.newFont(size)
	return fonts[size]
end

function lostgame()
    writestats()
    songfadeout:start()
	if deathText()=="The LSD wears off" then
	    song:setPitch(.8)
		deathtexts[11] = "MOAR LSD"
		deathtexts[17] = "MOAR LSD"
		deathtexts[16] = "MOAR LSD"
		deathtexts[14] = "MOAR LSD"
		currentPE = noLSD_PE
		currentPET = noLSD_PET
	elseif deathText()=="MOAR LSD" then
	    song:setPitch(1)
	    deathtexts[11] = "The LSD wears off"
	    deathtexts[17] = "There is no cake\n   also you died"
	    deathtexts[16] = "Have a nice death"
	    deathtexts[14] = "USPGameDev Rulez"
		currentPE = nil 
		currentPET = nil
	end

    gamelost = true
    timefactor = .05
    psycho.speed:set(0,0)
    if psycho.ultrameter then psycho.ultrameter.sizeGrowth = -300 end
    neweffects(psycho,80)
end

function color(x,xt,alpha)
	xt = xt or colortimer.timelimit
	x = x % xt
	local r,g,b
	if x<=xt/3 then
		r = 100 		 -- 100%
		g = 100*x/(xt/3) -- 0->100%
		b = 0 			 -- 0%
	elseif x<=xt/2 then
		r = 100*(1 - ((x-xt/3)/(xt/2-xt/3))) -- 100->0%
		g = 100 - 20*((x-xt/3)/(xt/2-xt/3))  -- 100->80%
		b = 0 								 -- 0%
	elseif x<=7*xt/12 then
		r = 0 								  -- 0%
		g = 80 - 20*((x-xt/2)/(7*xt/12-xt/2)) -- 80->60%
		b = 60*((x-xt/2)/(7*xt/12-xt/2)) 	  -- 0->60%
	elseif x<=255*xt/360 then
		r = 11*((x-7*xt/12)/(255*xt/360-7*xt/12)) 	   -- 0->11%
		g = 60 -49*((x-7*xt/12)/(255*xt/360-7*xt/12))  -- 60->11%
		b = 60 + 10*((x-7*xt/12)/(255*xt/360-7*xt/12)) -- 60->70%
	elseif x<=318*xt/360 then
		r = 11 + 59*((x-255*xt/360)/(318*xt/360-255*xt/360))  -- 11->70%
		g = 11*(1 - ((x-255*xt/360)/(318*xt/360-255*xt/360))) -- 11->0%
		b = 70 - 10*((x-255*xt/360)/(318*xt/360-255*xt/360))  -- 70->60%
	else
		r = 70 + 30*((x-318*xt/360)/(xt-318*xt/360))  -- 70->100%
		g = 0 										  -- 0%
		b = 60*(1 - ((x-318*xt/360)/(xt-318*xt/360))) -- 60->0%
	end
	
	return {r*2.55,g*2.55,b*2.55,alpha or 255}
end

function sign(x)
    if x>0 then return 1
    elseif x<0 then return -1
    else return 0 end
end

function line()
	if gamelost then return end
	graphics.setColor(color(colortimer.time+12))
	graphics.circle("line",mouse.getX(),mouse.getY(),5)
	graphics.setColor(color(colortimer.time+12,nil,60))
	local m = (mouse.getY()-psycho.y)/(mouse.getX()-psycho.x)
	local x,y
	if (mouse.getX()-psycho.x)>0 then 
		x = graphics.getWidth()
		y = psycho.y + (x-psycho.x)*m
	else
		x = 0
		y = psycho.y + (x-psycho.x)*m
	end
	graphics.line(psycho.x,psycho.y,x,y)
end

function love.draw()
	graphics.setPixelEffect(currentPE) --things without texture
    graphics.setLine(4)
	local bc = color(colortimer.time+17*colortimer.timelimit/13)
	bc[1] = bc[1]/7
	bc[2] = bc[2]/7
	bc[3] = bc[3]/7
	graphics.setColor(bc)
	graphics.rectangle("fill",0,0,graphics.getWidth(),graphics.getHeight()) --background color

    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			m:draw()
		end
    end

	graphics.setColor(color(colortimer.time*1.4))
	graphics.setLine(1)

	for i=enemylist.first,enemylist.last-1 do
		local a = math.atan((enemylist[i].speed.y/enemylist[i].speed.x))
		if enemylist[i].speed.x<0 then a = a + math.pi end
		graphics.arc("line", enemylist[i].x, enemylist[i].y, 30, a-.15, a+.15)
	end
	line()

	--painting PsyChObALL
	psycho:draw()
	
	
    graphics.setPixelEffect(currentPET) --things with textures
    graphics.print(string.format("Score: %.0f",score),25,22)
    graphics.print(string.format("Time: %.1fs",totaltime),25,68)
	graphics.print(srt,27,96)
	graphics.print("FPS: " .. love.timer.getFPS(),1000,23)
	graphics.print(string.format("Best Time: %.1fs",math.max(besttime,totaltime)),25,46)
	if multiplier>bestmult then bestmult = multiplier end
	graphics.print(string.format("Best Mult: x%.1f",bestmult),965,103)
	graphics.setFont(getFont(40))
	graphics.print(string.format("x%.1f",multiplier),950,55)
	graphics.setFont(getFont(12))
	
	
	if firsttime then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		graphics.setFont(getFont(20))
		graphics.print("You get points when:",270,36)
		graphics.print("You kill an enemy",303,72)
		graphics.print("You lose points when:",607,36)
		graphics.print("You miss a shot",641,72)
		graphics.print("You let an enemy escape",641,95)
		graphics.setFont(getFont(30))
		graphics.print("Game Ends when your score hits zero",135,564)
		graphics.setFont(getFont(20))
		graphics.print("Use WASD or arrows to move",202,300)
		graphics.print("Click to shoot",560,390)
		graphics.print("Hold space to charge:", 540,432)
		graphics.print("click to continue",870,645)
		graphics.setFont(getFont(17))
		graphics.print("Or when you die.",730,600)
		graphics.setFont(getFont(12))
		graphics.print("v" .. version,1030,679)
		if latest==version then
			graphics.print("Version up to date!",945,696)
		else
			graphics.print("Version " .. latest,827,696)
			graphics.print("is available to download!",915,696)
		end
		graphics.print("A game by Marvellous Soft/USPGameDev", 14,696)
		graphics.setFont(getFont(35))
		graphics.setColor(color(colortimer.time*0.856))
		graphics.print("ulTrAbLaST",762,420)

		graphics.setColor(color(colortimer.time*4.5 + .54))
		graphics.draw(logo,120,105,nil,0.25,0.20)
		graphics.setFont(getFont(12))
	end
	if gamelost then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		if besttime == totaltime then
			graphics.setFont(getFont(60))
			graphics.print("You beat the best time!",182,144)
		end
		graphics.setFont(getFont(40))
		graphics.print(deathText(),270,300)
		graphics.setFont(getFont(30))
		graphics.print(string.format("You lasted %.1fsecs",totaltime),486,600)
		if score==0 then graphics.print("Your score hit 0.",432,640) end
		graphics.setFont(getFont(22))
		graphics.print("'r' to retry",540,480)
		graphics.setFont(getFont(12))
	end
	if esc then
		graphics.setColor(color(colortimer.time-colortimer.timelimit/2))
		graphics.setFont(getFont(40))
		graphics.print("Paused",270,300)
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
	if not gamelost and score<=0 then score=0 lostgame() end
	
	
	timer.updatetimers(dt,timefactor,isPaused,gamelost)
	
	dt = dt*timefactor
	
	if isPaused then return end
	if not gamelost then totaltime = totaltime+dt end

    psycho:update(dt)
    local todelete = {}
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			if not m:update(dt) then
				table.insert(todelete,j) --deletes items that return false
			end
		end
		local a=0
		for k,n in ipairs(todelete) do
			if type(n) == 'number' then
				v[n-a]:handleDelete()
				table.remove(v,n-a)
				a = a+1
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

function love.mousepressed(x,y,button)
    if esc or pause then return end
    if firsttime then firsttime = false return end
    if button == 'l' and not gamelost then
        shoot(x,y)
		shottimer:start()
    end
end

function love.mousereleased(x,y,button)
	if button == 'l' then
		shottimer:stop()
	end
end

function shoot(x,y)
	local diffx = x - psycho.x
    local diffy = y - psycho.y
    local Vx = signum(diffx)*math.sqrt((9*v*v*diffx*diffx)/(diffx*diffx + diffy*diffy))
    local Vy = signum(diffy)*math.sqrt((9*v*v*diffy*diffy)/(diffx*diffx + diffy*diffy))
    table.insert(shot.bodies, shot:new {
    	position = psycho.position:clone(),
    	speed	 = vector:new {Vx,Vy}
    	})
end

function signum(a)
    if a>0 then return 1
    elseif a<0 then return -1
    else return 0 end
end

function addscore(x)
	if not gamelost then
		score = score + x
	end
end

function love.keypressed(key,code)
	
	if (key=='escape' or key=='p') and not gamelost then esc = not esc end

	if not gamelost then 
	    if key=='w' or key == 'up' then
	        psycho.Vy = -v
	  		if psycho.Vx~=0 then psycho.speed:div(sqr2) end
	    elseif key=='s' or key == 'down' then 
	        psycho.Vy = v
	        if psycho.Vx~=0 then psycho.speed:div(sqr2) end
	    elseif key=='a' or key=='left' then 
	        psycho.Vx = -v
	        if psycho.Vy~=0 then psycho.speed:div(sqr2) end
	    elseif key=='d' or key=='right' then 
	        psycho.Vx = v
	        if psycho.Vy~=0 then psycho.speed:div(sqr2) end
	    end

		if key == ' ' and not isPaused then
			ultrablast = 10
			psycho.ultrameter = circleEffect:new {
				based_on = psycho,
				sizeGrowth = 30,
				alpha = 100,
				linewidth = 6,
				index = 'ultrameter'
			}
			psycho.ultrameter.position = psycho.position
			ultratimer:start()
		end
	end
	
	if gamelost and key=='r' then
		local x,y
		if psycho.diereason == "shot" then
			x = psycho.x
			y = psycho.y
		end
		reload()
		psycho.x = x or psycho.x
		psycho.y = y or psycho.y
	end
end

function do_ultrablast()
	for i=1,ultrablast do
		shoot(psycho.x+(math.cos(math.pi*2*i/ultrablast)*100),psycho.y+(math.sin(math.pi*2*i/ultrablast)*100))
	end
end

function love.keyreleased(key,code)
	if not gamelost then
	    if ((key=='w'or key=='up') and (keyboard.isDown('s') or keyboard.isDown('down'))) then
	        psycho.Vy = math.abs(psycho.Vy)
	    elseif ((key=='s'or key=='down') and (keyboard.isDown('w') or keyboard.isDown('up'))) then
	        psycho.Vy = -math.abs(psycho.Vy)
	    elseif ((key=='a'or key=='left') and (keyboard.isDown('d') or keyboard.isDown('right'))) then
	        psycho.Vx = math.abs(psycho.Vx)
	    elseif  ((key=='d'or key=='right') and (keyboard.isDown('a') or keyboard.isDown('left'))) then
	        psycho.Vx = -math.abs(psycho.Vx)
	    end
	    
	    if (key=='w' or key=='s' or key=='up' or key=='down') and 
	            not (keyboard.isDown('w') or keyboard.isDown('s') or 
	                keyboard.isDown('up') or keyboard.isDown('down')) then 
		    psycho.speed:set(signum(psycho.Vx) * v, 0)
	    elseif (key=='a' or key=='d' or key=='left' or key=='right') and 
	            not (keyboard.isDown('a') or keyboard.isDown('d') or 
	                keyboard.isDown('left') or keyboard.isDown('right')) then 
			psycho.speed:set( 0, signum(psycho.Vy) * v)
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
	
	if key=='scrollock' then 
	    graphics.newScreenshot():encode('screenshot_' .. screenshotnumber .. '.png')
	    screenshotnumber = screenshotnumber + 1
	end
end

function love.focus(f)
    pause = not f
end
