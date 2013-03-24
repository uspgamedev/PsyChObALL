require "circleEffect"
require "effect"

sqr2 = math.sqrt(2)

crt = 10 --color reset time
ct = 0
firsttime = true
besttime = 0.0

love.filesystem.setIdentity("PsyChObALL")
song = love.audio.newSource("Hydrogen.mp3")
song:play()
song:setLooping(true)
rpc=-1 --reset pitch counter
rpl=.2 --reset pitch limit
love.graphics.setMode(1080,720)

function rbesttime()
    local file = love.filesystem.newFile("high")
    if not love.filesystem.exists("high") then
        file:open('w')
        file:close()
    end
    file:open('r')
    local r = file:read()
    if r=='' then return end
    besttime = besttime + r
end

rbesttime()

function wbesttime()
    local file = love.filesystem.newFile("high")
    file:open('w')
    file:write(totaltime)
    besttime = totaltime
    file:close()
end

function love.load()
	v = 220
	
	circle = {}
	circle.x,circle.y = relative(400,300)
	circle.Vx = 0
	circle.Vy = 0
	circle.size = 23
	function circle:update(dt)
		self.x = self.x + 1.65*self.Vx*dt
		self.y = self.y + 1.65*self.Vy*dt
		for i,v in pairs(enemies) do
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
	shots = {}
	effects = {}
	circles = {}
	enemies = {}
	paintables[1] = circles
	paintables[2] = shots
	paintables[3] = enemies
	paintables[4] = effects

	etc = 0 --enemy time counter
	etl = 2 --enemy time limit
	emin = .14 -- enemy min time
	
	stc = 0 --shot time counter
	stl = 0.18 --shot time limit
	
	ctc=0 --circle time counter
	ctl=.2 --circle time limit
	
	totaltime = 0
	
	timefactor = 1.0
	

	score = 200

	pause = false
	gamelost = false
	esc = false

	srt = " " --random string to be painted
	dtn = nil
end


function relative(x,y)
	return x*love.graphics.getWidth()/800,y*love.graphics.getHeight()/600
end

function lostgame()
    if totaltime > besttime then wbesttime() end
	if deathText()=="The LSD wears off" then
		color = colorbland
		deathtexts[11] = "MOAR LSD"
	elseif deathText()=="MOAR LSD" then
	    color = colorbak
	    deathtexts[11] = "The LSD wears off"
	end
    --outras coisas
    gamelost = true
end

function color(x,xt,alpha)
	xt = xt or crt
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
colorbak = color

function colorbland(a,b,alpha)
	b = b or crt
	a = a % b
	local c = 100
	if a<b/2 then
		c = (2*a/b)*150 + 50
	else
		c = 200 - (2*(a-b/2)/b)*150
	end
	return {c,c,c,alpha or 255}
end

function sign(x)
    if x>0 then return 1
    elseif x<0 then return -1
    else return 0 end
end

function newEnemy(s)
    s = s or 15
    local enemy = {}
	local side = math.random(4)
	if		side==1 then --top
		enemy.x = math.random(15,love.graphics.getWidth()-s-1)
		enemy.y = 1
		enemy.Vy = math.random(v,v+50)
		local n = -1
		if enemy.x<love.graphics.getWidth()/2 then n = 1 end
		enemy.Vx = n*math.random(0,v)
		n = nil
	elseif	side==2 then --bottom
		enemy.x = math.random(15,love.graphics.getWidth()-s-1)
		enemy.y = love.graphics.getHeight()-1
		enemy.Vy = -math.random(v,(v+50))
		local n = -1
		if enemy.x<love.graphics.getWidth()/2 then n = 1 end
		enemy.Vx = n*math.random(0,v)
		n = nil
	elseif	side==3 then --left
		enemy.x = 1
		enemy.y = math.random(15,love.graphics.getHeight()-s-1)
		enemy.Vx = math.random(v,v+50)
		local n = -1
		if enemy.y<love.graphics.getHeight()/2 then n = 1 end
		enemy.Vy = n*math.random(0,v)
		n = nil
	elseif side==4 then --right
		enemy.x = love.graphics.getWidth()-1
		enemy.y = math.random(15,love.graphics.getHeight()-s-1)
		enemy.Vx = -math.random(v,v+50)
		local n = -1
		if enemy.y<love.graphics.getHeight()/2 then n = 1 end
		enemy.Vy = n*math.random(0,v)
		n = nil
	end
    enemy.variance = math.random(crt*1000)/1000
    enemy.color = color(math.random(0,100*crt)/100)
    enemy.size = s
    enemy.typ = "enemy"
    enemy.collides = false
    enemy.diereason = "leftscreen"
    function enemy:handleDelete()
        if self.diereason=="shot" then
			score = score + self.size/3
			effect.new(self.x,self.y,10,effects)
			if self.size>=15 then table.insert(circles,circleEffect.new(self,10,100,600,love.graphics.getWidth())) end
        elseif self.size>=15 then score = score - 3 end
		if self.size>=10 then 
			local momentum = true
			for i=1,3 do
				local e = newEnemy(self.size-5)
				e.x = self.x
				e.y = self.y
				e.Vx = math.random(v)-v/2 + 1.3*self.Vx
				e.Vy = math.random(v)-v/2 + 1.3*self.Vy
				if e.Vy+e.Vx<10 then e.Vy = signum(self.Vy)*math.random(3*v/4,v) end
				e.variance = self.variance
				table.insert(enemies,e)
			end
		end
		effect.new(self.x,self.y,4,effects)
    end
    s = nil
    function enemy:draw()
		self.color = color(ct+self.variance)
		love.graphics.setColor(self.color)
        love.graphics.circle("fill",self.x,self.y,self.size)
    end
    function enemy:update(dt)
        for i,v in pairs(shots) do
            if (v.size+self.size)*(v.size+self.size)>=(v.x-self.x)*(v.x-self.x)+(v.y-self.y)*(v.y-self.y) then
                self.collides = true
                v.collides = true
                self.diereason = "shot"
                break
            end
        end
        self.x = self.x + self.Vx*dt
        self.y = self.y + self.Vy*dt
        return not(self.collides or self.x<-self.size or self.y<-self.size or self.x-self.size>love.graphics.getWidth() or self.y-self.size> love.graphics.getHeight())
    end
    return enemy
end

function newShot(x,y,Vx,Vy)
    local shot = {}
    shot.x = x
    shot.y = y
    shot.Vx = Vx
    shot.Vy = Vy
    shot.size = 4
    shot.typ = "shot"
    shot.collides = false
	shot.variance = math.random(0,100*crt)/100
    function shot:handleDelete()
		score = score-2
		effect.new(self.x,self.y,7,effects)
    end
    function shot:draw()   
		love.graphics.setColor(color(self.variance+ct))
        love.graphics.circle("fill",self.x,self.y,self.size)
    end
    function shot:update(dt)
        self.x = self.x + self.Vx*dt
        self.y = self.y + self.Vy*dt
        return not(self.collides or self.x<-self.size or self.y<-self.size or self.x+self.size>love.graphics.getWidth() or self.y+self.size> love.graphics.getHeight())
    end
    return shot
end

function love.draw()
    love.graphics.setLine(4)
	local bc = color(ct+17*crt/13)
	bc[1] = bc[1]/7
	bc[2] = bc[2]/7
	bc[3] = bc[3]/7
    love.graphics.setBackgroundColor(bc)
    for i,v in pairs(paintables) do
        for j,m in pairs(v) do
			m:draw()
		end
    end
    love.graphics.setColor(color(ct))
    love.graphics.circle("fill", circle.x,circle.y,circle.size)
    love.graphics.print(string.format("Score: %.0f",score),relative(20,20))
    love.graphics.print(string.format("Time: %.1fs",totaltime),relative(20,60))
	love.graphics.print(srt,relative(20,80))
	love.graphics.print("FPS: " .. love.timer.getFPS(),relative(740,20))
	love.graphics.print(string.format("Best Time: %.1fs",math.max(besttime,totaltime)),relative(20,40))
	if firsttime then
		love.graphics.setColor(color(ct-crt/2))
		local deffont = love.graphics.getFont()
		love.graphics.setFont(love.graphics.newFont(20))
		love.graphics.print("You get points when:",relative(200,30))
		love.graphics.print("You kill an enemy",relative(225,60))
		love.graphics.print("You lose points when:",relative(500,30))
		love.graphics.print("You miss a shot",relative(525,60))
		love.graphics.print("You let an enemy escape",relative(525,80))
		love.graphics.setFont(love.graphics.newFont(30))
		love.graphics.print("Game Ends when your score hits zero",relative(100,470))
		love.graphics.setFont(love.graphics.newFont(20))
		love.graphics.print("Use WASD or arrows to move",relative(150,250))
		love.graphics.print("Click to shoot",relative(415,325))
		love.graphics.print("click to continue",relative(650,560))
		love.graphics.setFont(deffont)
		love.graphics.print("Or when you die.",relative(570,500))
		
	end
	if gamelost then
		love.graphics.setColor(color(ct-crt/2))
		local deffont = love.graphics.getFont()
		if besttime == totaltime then
			love.graphics.setFont(love.graphics.newFont(60))
			love.graphics.print("You beat the best time!",relative(100,100))
		end
		love.graphics.setFont(love.graphics.newFont(40))
		love.graphics.print(deathText(),relative(200,250))
		love.graphics.setFont(love.graphics.newFont(30))
		love.graphics.print(string.format("You lasted %.1fsecs",totaltime),relative(360,440))
		love.graphics.setFont(love.graphics.newFont(22))
		love.graphics.print("'r' to retry",relative(400,400))
		love.graphics.setFont(deffont)
	end
	if esc then
		love.graphics.setColor(color(ct-crt/2))
		local deffont = love.graphics.getFont()
		love.graphics.setFont(love.graphics.newFont(40))
		love.graphics.print("Paused",relative(200,250))
		love.graphics.setFont(deffont)
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
	if score<=0 then score=0 lostgame() end
	if not (gamelost or esc or pause or firsttime) then totaltime = totaltime+dt end
	
	dt = dt*timefactor
	ct = ct + dt
	if ct>=crt then ct=0 end
	if rpc>-1 then 
		rpc = rpc+dt
		if rpc>rpl then rpc = -1 song:setPitch(1) end
	end
	
	if pause or esc or gamelost or firsttime then return end
	
	ctc = ctc+dt
	if ctc>ctl then 
	ctc = 0 
	table.insert(circles,circleEffect.new(circle))
	for i,v in pairs(enemies) do
		if v.size>=10 then table.insert(circles,circleEffect.new(v)) end
	end
	end
	
	
	
	if mousedown then 
		stc = stc + dt
		if stc>=stl then
			stc = stc-stl
			shoot(love.mouse.getPosition())
		end
	end
	
    
    etc = etc + dt
    if etc>etl then
        etc = 0
        etl = emin + (etl-emin)/1.09
        table.insert(enemies,newEnemy())
    end
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
		mousedown = true
		stc = 0
    end
end
function love.mousereleased(x,y,button)
	if pause then return end
	if button == 'l' then
		mousedown = false
		stc = 0
	end
end

function shoot(x,y)
	local diffx = x - circle.x
    local diffy = y - circle.y
    local Vx = signum(diffx)*math.sqrt((9*v*v*diffx*diffx)/(diffx*diffx + diffy*diffy))
    local Vy = signum(diffy)*math.sqrt((9*v*v*diffy*diffy)/(diffx*diffx + diffy*diffy))
    table.insert(shots, newShot(circle.x,circle.y,Vx,Vy))
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
		love.load()
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
