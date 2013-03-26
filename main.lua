require "global"
require "circleEffect"
require "effect"
require "enemy"
require "shot"
require "timer"

function rbesttime()
    local file = love.filesystem.newFile("high")
    if not love.filesystem.exists("high") then
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



function wbesttime()
    local file = love.filesystem.newFile("high")
    file:open('w')
    if totaltime>besttime then besttime = totaltime end
    file:write(besttime .. "\n" .. bestmult)
    file:close()
end

function love.load()
    version = "0.9.3"
	love.graphics.setMode(1080,720)
	timer.ts = {}
	reload() -- reload()-> things that should be resetted when player dies, the rest-> one time only
	
	sqr2 = math.sqrt(2)
	fonts = {}
	
	global.colortimer = timer.new(10,nil,true,false,false,true,true)
	firsttime = true
	rbesttime()
	
	
	v = 220
	
	global.currentPE = nil
	global.currentPET = nil
	global.noLSD_PET = love.graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
    global.noLSD_PE = love.graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4((cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, (cor_final[0]+cor_final[1]+cor_final[2])/3, cor_final[3]);
        }
    ]]
	global.invertPET = love.graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = Texel(texture, texture_coords) * color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
    global.invertPE = love.graphics.newPixelEffect [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 cor_final = color;
            return vec4(1-cor_final[0],1-cor_final[1],1-cor_final[2], cor_final[3]);
        }
    ]]
	
	global.multtimer = timer.new(1.5,function() global.multiplier = 1 end,false,false,true,true,true,function(self) self:stop() self.func(self) end)
	global.inverttimer = timer.new(1.5,function()
	     if global.currentPE ~= global.LSD_PE then 
	        global.currentPE = nil 
	        global.currentPET = nil 
	    end
	end,false,false,true,true,true)
	
	love.filesystem.setIdentity("PsyChObALL")
	song = love.audio.newSource("Hydrogen.mp3")
	song:play()
	song:setLooping(true)
	
end

function reload()
	timer.closenonessential()
	
	circle = {}
	circle.x,circle.y = relative(380,300)
	circle.Vx = 0
	circle.Vy = 0
	circle.size = 23
	function circle:update(dt)
		self.x = self.x + 1.65*self.Vx*dt
		self.y = self.y + 1.65*self.Vy*dt
		for i,v in pairs(enemy.bodies) do
			if (v.size+self.size)*(v.size+self.size)>=(v.x-self.x)*(v.x-self.x)+(v.y-self.y)*(v.y-self.y) then
				lostgame()
				self.diereason = "shot"
			elseif (self.collides or self.x<-self.size or self.y<-self.size or self.x+self.size>love.graphics.getWidth() or self.y+self.size> love.graphics.getHeight()) then
				self.diereason = "leftbounds"
				lostgame()
			end
		end
	end
	
	paintables = {}
	shot.bodies = {}
	effect.bodies = {}
	circleEffect.bodies = {}
	enemy.bodies = {}
	paintables[1] = circleEffect.bodies
	paintables[2] = shot.bodies
	paintables[3] = enemy.bodies
	paintables[4] = effect.bodies
	
	enemytimer = timer.new(2,function(self)
			self.timelimit = .14 + (self.timelimit-.14)/1.09
			table.insert(enemy.bodies,enemy.new())
		end)
	
	shottimer = timer.new(.18,function() shoot(love.mouse.getPosition()) end,false)
	
	global.multiplier = 1
	
	
	circletimer = timer.new(.2,function()
			circleEffect.new(circle)
			for i,v in pairs(enemy.bodies) do
				if v.size>=10 then circleEffect.new(v) end
			end
		end)
	
	totaltime = 0
	
	timefactor = 1.0
	
	global.score = 200

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil
end

function getFont(size)
	if fonts[size] then return fonts[size] end
	fonts[size] = love.graphics.newFont(size)
	return fonts[size]
end

function relative(x,y)
	return x*love.graphics.getWidth()/800,y*love.graphics.getHeight()/600
end

function lostgame()
    wbesttime()
	if deathText()=="The LSD wears off" then
		deathtexts[11] = "MOAR LSD"
		global.currentPE = global.noLSD_PE
		global.currentPET = global.noLSD_PET
	elseif deathText()=="MOAR LSD" then
	    deathtexts[11] = "The LSD wears off"
		global.currentPE = nil 
		global.currentPET = nil
	end
    --outras coisas
    gamelost = true
end

function color(x,xt,alpha)
	xt = xt or global.colortimer.timelimit
	x = x % xt
	local r,g,b
	if x<=xt/3 then
		r = 100 -- 100%
		g = 100*x/(xt/3) -- 0->100%
		b = 0 -- 0%
	elseif x<=xt/2 then
		r = 100*(1 - ((x-xt/3)/(xt/2-xt/3))) -- 100->0%
		g = 100 - 20*((x-xt/3)/(xt/2-xt/3)) --100->80%
		b = 0 -- 0%
	elseif x<=7*xt/12 then
		r = 0 -- 0%
		g = 80 - 20*((x-xt/2)/(7*xt/12-xt/2)) -- 80->60%
		b = 60*((x-xt/2)/(7*xt/12-xt/2)) -- 0->60%
	elseif x<=255*xt/360 then
		r = 11*((x-7*xt/12)/(255*xt/360-7*xt/12)) -- 0->11%
		g = 60 -49*((x-7*xt/12)/(255*xt/360-7*xt/12)) -- 60->11%
		b = 60 + 10*((x-7*xt/12)/(255*xt/360-7*xt/12)) --60->70%
	elseif x<=318*xt/360 then
		r = 11 + 59*((x-255*xt/360)/(318*xt/360-255*xt/360)) -- 11->70%
		g = 11*(1 - ((x-255*xt/360)/(318*xt/360-255*xt/360))) -- 11->0%
		b = 70 - 10*((x-255*xt/360)/(318*xt/360-255*xt/360)) -- 70->60%
	else
		r = 70 + 30*((x-318*xt/360)/(xt-318*xt/360)) -- 70->100%
		g = 0 -- 0%
		b = 60*(1 - ((x-318*xt/360)/(xt-318*xt/360))) --60->0%
	end
	
	return {r*2.55,g*2.55,b*2.55,alpha or 255}
end

function sign(x)
    if x>0 then return 1
    elseif x<0 then return -1
    else return 0 end
end

function love.draw()
	love.graphics.setPixelEffect(global.currentPE)
    love.graphics.setLine(4)
	local bc = color(global.colortimer.time+17*global.colortimer.timelimit/13)
	bc[1] = bc[1]/7
	bc[2] = bc[2]/7
	bc[3] = bc[3]/7
    --love.graphics.setBackgroundColor(bc)
	love.graphics.setColor(bc)
	love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight()) --background color
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			m:draw()
		end
    end
    love.graphics.setColor(color(global.colortimer.time))
    love.graphics.circle("fill", circle.x,circle.y,circle.size)
    love.graphics.setPixelEffect(global.currentPET)
    love.graphics.print(string.format("Score: %.0f",global.score),relative(20,20))
    love.graphics.print(string.format("Time: %.1fs",totaltime),relative(20,60))
	love.graphics.print(srt,relative(20,80))
	love.graphics.print("FPS: " .. love.timer.getFPS(),relative(740,20))
	love.graphics.print(string.format("Best Time: %.1fs",math.max(besttime,totaltime)),relative(20,40))
	if global.multiplier>bestmult then bestmult = global.multiplier end
	love.graphics.print(string.format("Best Mult: x%.1f",bestmult),relative(715,86))
	love.graphics.setFont(getFont(40))
	love.graphics.print(string.format("x%.1f",global.multiplier),relative(700,50))
	love.graphics.setFont(getFont(12))
	
	
	if firsttime then
		love.graphics.setColor(color(global.colortimer.time-global.colortimer.timelimit/2))
		love.graphics.setFont(getFont(20))
		love.graphics.print("You get points when:",relative(200,30))
		love.graphics.print("You kill an enemy",relative(225,60))
		love.graphics.print("You lose points when:",relative(500,30))
		love.graphics.print("You miss a shot",relative(525,60))
		love.graphics.print("You let an enemy escape",relative(525,80))
		love.graphics.setFont(getFont(30))
		love.graphics.print("Game Ends when your score hits zero",relative(100,470))
		love.graphics.setFont(getFont(20))
		love.graphics.print("Use WASD or arrows to move",relative(150,250))
		love.graphics.print("Click to shoot",relative(415,325))
		love.graphics.print("click to continue",relative(650,560))
		love.graphics.setFont(getFont(12))
		love.graphics.print("Or when you die.",relative(570,500))
		love.graphics.print("v" .. version,relative(750,580))
	end
	if gamelost then
		love.graphics.setColor(color(global.colortimer.time-global.colortimer.timelimit/2))
		if besttime == totaltime then
			love.graphics.setFont(getFont(60))
			love.graphics.print("You beat the best time!",relative(100,100))
		end
		love.graphics.setFont(getFont(40))
		love.graphics.print(deathText(),relative(200,250))
		love.graphics.setFont(getFont(30))
		love.graphics.print(string.format("You lasted %.1fsecs",totaltime),relative(360,440))
		love.graphics.setFont(getFont(22))
		love.graphics.print("'r' to retry",relative(400,400))
		love.graphics.setFont(getFont(12))
	end
	if esc then
		love.graphics.setColor(color(global.colortimer.time-global.colortimer.timelimit/2))
		love.graphics.setFont(getFont(40))
		love.graphics.print("Paused",relative(200,250))
		love.graphics.setFont(getFont(12))
	end
end

deathtexts = {"Game Over", "No one will\n miss you","You now lay\n   with the dead","Yo momma so fat\n   you died",
"You ceased to exist","Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?",
"All your base\n are belong to BALLS","You wake up and\n realize it was all a nightmare","The LSD wears off",
"MIND BLOWN","Just one more"}
function deathText()
	dtn = dtn or deathtexts[math.random(table.getn(deathtexts))]
	return dtn
end

function love.update(dt)
	local isPaused = (gamelost or esc or pause or firsttime) 
	if global.score<=0 then global.score=0 lostgame() end
	if not isPaused then totaltime = totaltime+dt end
	
	timer.update(dt,timefactor,isPaused)
	
	dt = dt*timefactor
	
	if isPaused then return end

    circle:update(dt)
    local todelete = {}
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			if not m:update(dt) then
			table.insert(todelete,j)
			end
		end
		local a=0
		for k,n in ipairs(todelete) do
			v[n-a]:handleDelete()
			table.remove(v,n-a)
			a = a+1
		end
		todelete = nil
		todelete = {}
    end
	todelete = nil
end

function love.mousepressed(x,y,button)
    if pause then return end
    if firsttime then firsttime = false return end
    if button == 'l' then
        shoot(x,y)
		shottimer:start()
    end
end
function love.mousereleased(x,y,button)
	if pause then return end
	if button == 'l' then
		shottimer:stop()
	end
end

function shoot(x,y)
	local diffx = x - circle.x
    local diffy = y - circle.y
    local Vx = signum(diffx)*math.sqrt((9*v*v*diffx*diffx)/(diffx*diffx + diffy*diffy))
    local Vy = signum(diffy)*math.sqrt((9*v*v*diffy*diffy)/(diffx*diffx + diffy*diffy))
    table.insert(shot.bodies, shot.new(circle.x,circle.y,Vx,Vy))
end

function signum(a)
    if a>0 then return 1
    elseif a<0 then return -1
    else return 0 end
end

function love.keypressed(key,code)
	
	if key=='escape' and not gamelost then esc = not esc end

    if key=='w' or key == 'up' then 
        circle.Vy = -v
        if circle.Vx>0 then circle.Vy = circle.Vy/sqr2 circle.Vx = circle.Vx/sqr2 end
    elseif key=='s' or key == 'down' then 
        circle.Vy = v
        if circle.Vx>0 then circle.Vy = circle.Vy/sqr2 circle.Vx = circle.Vx/sqr2 end
    elseif key=='a' or key=='left' then 
        circle.Vx = -v
        if circle.Vy>0 then circle.Vx = circle.Vx/sqr2 circle.Vy = circle.Vy/sqr2 end
    elseif key=='d' or key=='right' then 
        circle.Vx = v 
        if circle.Vy>0 then circle.Vx = circle.Vx/sqr2 circle.Vy = circle.Vy/sqr2 end
    end
	
	if gamelost and key=='r' then
		local x,y
		if circle.diereason == "shot" then
			x = circle.x
			y = circle.y
		end
		reload()
		circle.x = x or circle.x
		circle.y = y or circle.y
	end
end

function love.keyreleased(key,code)
    if ((key=='w'or key=='up') and (love.keyboard.isDown('s') or love.keyboard.isDown('down')))then
        circle.Vy = math.abs(circle.Vy)
    elseif ((key=='s'or key=='down') and (love.keyboard.isDown('w') or love.keyboard.isDown('up'))) then
        circle.Vy = -math.abs(circle.Vy)
    elseif ((key=='a'or key=='left') and (love.keyboard.isDown('d') or love.keyboard.isDown('right'))) then
        circle.Vx = math.abs(circle.Vx)
    elseif  ((key=='d'or key=='right') and (love.keyboard.isDown('a') or love.keyboard.isDown('left'))) then
        circle.Vx = -math.abs(circle.Vx)
    end
    
    if (key=='w' or key=='s' or key=='up' or key=='down') and 
            not (love.keyboard.isDown('w') or love.keyboard.isDown('s') or 
                love.keyboard.isDown('up') or love.keyboard.isDown('down')) then 
		circle.Vy=0
	    circle.Vx = signum(circle.Vx) * v
    elseif (key=='a' or key=='d' or key=='left' or key=='right') and 
            not (love.keyboard.isDown('a') or love.keyboard.isDown('d') or 
                love.keyboard.isDown('left') or love.keyboard.isDown('right')) then 
	circle.Vx=0 
	circle.Vy = signum(circle.Vy) * v
	end
end

function love.focus(f)
    pause = not f
end
