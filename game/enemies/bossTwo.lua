local max, random, abs, pairs = math.max, math.random, math.abs, pairs

bossTwo = CircleEffect:new {
	size = 80,
	maxhealth = 35,
	basespeed = v,
	basespeedsqrt = math.sqrt(v),
	index = false,
	ballspos = 49,
	alpha = 255,
	mode = 'fill',
	sizeGrowth = 0,
	vulnerable = true,
	shader = Base.circleShader,
	maxsize = width,
	ord = 7,
	__type = 'bossTwo'
}

Body.makeClass(bossTwo)

bossTwo.behaviors = {}

function bossTwo:__init()
	self.variance = 6
	self.position:set(200, 200)
	self.ballspeed = 0
	self.ballscolors = {
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}}
	}
	self.ballscoloreffects = {
		ColorManager.getColorEffect(self.ballscolors[1][1], self.ballscolors[1][2], self.ballscolors[1][3], 20),
		ColorManager.getColorEffect(self.ballscolors[2][1], self.ballscolors[2][2], self.ballscolors[2][3], 20),
		ColorManager.getColorEffect(self.ballscolors[3][1], self.ballscolors[3][2], self.ballscolors[3][3], 20),
		ColorManager.getColorEffect(self.ballscolors[4][1], self.ballscolors[4][2], self.ballscolors[4][3], 20)
	}
	bossTwo.turrets = { 
		bossTwo.turret:new{ position = Vector:new{ 0, -50 } }, 
		bossTwo.turret:new{ position = Vector:new{  50, 0 } }, 
		bossTwo.turret:new{ position = Vector:new{ 0,  50 } }, 
		bossTwo.turret:new{ position = Vector:new{ -50, 0 } }
	}
	self.healths = { bossTwo.maxhealth, bossTwo.maxhealth, bossTwo.maxhealth, bossTwo.maxhealth }
	self.currentBehavior = bossTwo.behaviors.arriving
	self.position:set(-200, -200)
	self.speed:set(width/2, height/2):sub(self.position):normalize():mult(1.5*self.basespeed, 1.5*self.basespeed)
	self.prevdist = self.position:distsqr(width/2, height/2)
	bossTwo.shot = Enemies.simpleball
	function bossTwo:getTurretShot()
		return Enemies.simpleball:new{ score = false }
	end
end

function bossTwo.behaviors.arriving( self )
	local curdist = self.position:distsqr(width/2, height/2)
	if curdist < 1 or curdist > self.prevdist then
		self.position:set(width/2, height/2)
		self.speed:reset()
		self.shoottimer = Timer:new {
			timelimit = 1.6,
			works_on_gameLost = false,
			time = random(),
			running = true
		}

		function self.shoottimer.funcToCall()
			local e = self:getShot()
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(self.position)):normalize():add(random()/10, random()/10):normalize():mult(1.5 * v, 1.5 * v)
			e:register()
		end

		Timer:new{ timelimit = 2, running = true, onceOnly = true, funcToCall = function()
			local pos = {{90, 90},{width - 90, 90},  {width - 90, height - 90}, {90, height - 90}}
				self.turretsoldpos = {0,0,0,0}
				for i = 1, 4 do 
					local t = bossTwo.turrets[i]
					self.turretsoldpos[i] = t.position + self.position
					t:detach(self.position)
					t.speed:set(pos[i]):sub(t.position):normalize():mult(bossTwo.basespeed, bossTwo.basespeed)
					t.target = pos[i]
					t.prevdist = t.position:distsqr(t.target)
				end
				Timer:new {
					timelimit = .1,
					running = true,
					funcToCall = function(timer)
						for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
						for i = 1, 4 do bossTwo.turrets[i].shoottimer:start(0) end
						timer:remove()
					end
				}
				self.sizeGrowth = -30
				self.ballspeed = -10
			end
		}
		self.currentBehavior = bossTwo.behaviors.first
	end
	self.prevdist = curdist
end

function bossTwo.behaviors.first( self )
	if self.size < 60 then self.sizeGrowth = 0 self.size = 60 end
	if self.ballspos < 35 then self.ballspeed = 0 self.ballspos = 35 end
	if self.sizeGrowth == 0 and self.size == 60 and self.ballspeed == 0 and self.ballspos == 35 and self.health/bossTwo.maxhealth <= .75 then
		RecordsManager.addScore(500)
		for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
		bossTwo.turrets[1].speed:set(v,  0)
		bossTwo.turrets[2].speed:set(0,  v)
		bossTwo.turrets[3].speed:set(-v, 0)
		bossTwo.turrets[4].speed:set(0, -v)
		self.currentBehavior = bossTwo.behaviors.second
		self.getShot = function () return Enemies.multiball:new{ score = false } end
		bossTwo.getTurretShot = self.getShot
		for i = 1, 4 do
			bossTwo.turrets[i].restrictToScreenThreshold = 20
			bossTwo.turrets[i].restrictToScreenSpeed = v
			self.healths[i] = bossTwo.maxhealth * .75
			local c = self.ballscolors[i]
			c[1]:setAndGo(nil, 0, 120)
			c[2]:setAndGo(nil, 50, 120)
			c[3]:setAndGo(nil, 140, 120)
		end
	end
end

function bossTwo.behaviors.second( self )
	for i = 1, 4 do bossOne.restrictToScreen(bossTwo.turrets[i]) end
	if self.health/bossTwo.maxhealth <= .5 then
		RecordsManager.addScore(750)
		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			local targ = self.turretsoldpos[i]
			t.onLocation = false
			t.target = targ
			t.prevdist = t.position:distsqr(targ)
			t.speed:set(targ):sub(t.position):normalize():mult(v,v)
			t.shoottimer:stop()

			local c = self.ballscolors[i]
			c[1]:setAndGo(nil, 122, 120)
			c[2]:setAndGo(nil, 122, 120)
			c[3]:setAndGo(nil, 122, 120)

		end
		self.vulnerable = false
		self.currentBehavior = bossTwo.behaviors.gathering
		self.getShot = function() return Enemies.glitchball:new{ score = false } end
		bossTwo.getTurretShot = self.getShot
		self.sizeGrowth = 30
		self.ballspeed = 10
	end
end

function bossTwo.behaviors.gathering( self )
	if self.size > bossTwo.size then self.sizeGrowth = 0 self.size = bossTwo.size end
	if self.ballspos > bossTwo.ballspos then self.ballspeed = 0 self.ballspos = bossTwo.ballspos end
	if self.sizeGrowth == 0 and self.ballspeed == 0 and self.size == bossTwo.size and self.ballspos == bossTwo.ballspos then
		for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			t:attach(self.position)
		end
		Timer:new {
			timelimit = 1,
			running = true,
			onceOnly = true,
			funcToCall = function()
				if self.currentBehavior ~= bossTwo.behaviors.third then return end
				for i = 1, 4 do
					local t = bossTwo.turrets[i]
					t.onLocation = false
					t.target = t.position:normalized():mult(width/2 - 90, height/2 - 90)
					t.speed:set(t.position):normalize():mult(bossTwo.basespeed)
					t.prevdist = t.position:distsqr(t.target)
					t.shoottimer:start(-4)
				end
				self.rotatetimer:start(0)
			end
		}
		Timer:new{
			timelimit = 3.5,
			running = true,
			onceOnly = true,
			funcToCall = function()
				for i = 1, 4 do
					local c = self.ballscolors[i]
					c[1]:setAndGo(nil, 80, 120)
					c[2]:setAndGo(nil, 90, 120)
					c[3]:setAndGo(nil, 0, 120)
					self.healths[i] = bossTwo.maxhealth * .5
				end
				self.vulnerable = true
			end
		}
		self.rotatetimer = Timer:new {
			timelimit = 2.5,
			funcToCall = function(timer )
				for i = 1, 4 do
					local t = bossTwo.turrets[i]
					local n = bossTwo.turrets[(i % 4) + 1]
					t.onLocation = false
					t.target = n.position:clone()
					t.speed:set(t.target):sub(t.position):normalize():mult(bossTwo.basespeed)
					t.prevdist = t.position:distsqr(t.target)
				end
			end
		}

		self.currentBehavior = bossTwo.behaviors.third
	end
end

function bossTwo.behaviors.third( self )
	if self.health/bossTwo.maxhealth <= .25 then
		RecordsManager.addScore(750)
		self.rotatetimer:remove()
		self.rotatetimer = nil
		local tpos = {{0, -150}, {150, 0}, {0, 150}, {-150, 0}}
		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			t.target = tpos[i]
			t.onLocation = false
			t.speed:set(t.target):sub(t.position):normalize():mult(v,v)
			t.prevdist = t.position:distsqr(t.target)
			t.shoottimer:stop()
			Timer:new{
				timelimit = .1,
				time = -1,
				running = true,
				funcToCall = function(timer)
					for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
					local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
					local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]
					c1.speed:set(c1.position):normalize():mult(v/4, v/4)
					c2.speed:set(c2.position):normalize():mult(v/4, v/4)
					c1.sizeGrowth = 10
					c2.sizeGrowth = 10
					c3.sizeGrowth = -10
					c4.sizeGrowth = -10
					timer:remove()
				end
			}

			local c = self.ballscolors[i]
			c[1]:setAndGo(nil, 122, 100)
			c[2]:setAndGo(nil, 122, 100)
			c[3]:setAndGo(nil, 122, 100)
		end
		self.sizeGrowth = -30
		self.ballspeed = -10
		self.shoottimer:stop()
		self.currentBehavior = bossTwo.behaviors.caging
	end
end

function bossTwo.behaviors.caging( self )
	if self.size < 60 then self.sizeGrowth = 0 self.size = 60 end
	if self.ballspos < 35 then self.ballspeed = 0 self.ballspos = 35 end
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
		local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]

		if c3 and c3.size <= 0 then t.circles[i] = nil end
		if c4 and c4.size <= 0 then t.circles[i == 3 and 1 or ((i % 4) + 2)] = nil end
		if c1.size > 50 then c1.sizeGrowth = 0 c1.size = 50 end
		if c2.size > 50 then c2.sizeGrowth = 0 c2.size = 50 end
		if abs(c1.x + c1.y) > 80 then c1.speed:set(0,0) c1.position:normalize():mult(80) end
		if abs(c2.x + c2.y) > 80 then c2.speed:set(0,0) c2.position:normalize():mult(80) end
	end
	if self.size == 60 and self.ballspos == 35 and self.sizeGrowth == 0 and self.ballspeed == 0 then
		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
			local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]
			if c3 or c4 then return end
			if c1.size ~= 50 or c2.size ~= 50 or c1.sizeGrowth ~= 0 or c2.sizeGrowth ~= 0 then return end
			if not (c1.speed:equals(0, 0) and c2.speed:equals(0, 0)) then return end
		end
		--dostuff
		self.currentBehavior = bossTwo.behaviors.fourth
		for i = 1, 4 do
			local c = self.ballscolors[i]
			c[1]:setAndGo(nil, 0, 100)
			c[2]:setAndGo(nil, 240, 100)
			c[3]:setAndGo(nil, 0, 100)

			local t = bossTwo.turrets[i]
			t.shoottimer:start()
			local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
			t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1] = nil, nil
			t.circles[1], t.circles[2] = c1, c2
			c1.growafter = Timer:new{
				timelimit = 1.5,
				funcToCall = function(timer)
					c1.sizeGrowth = 3
					timer:stop()
				end
			}
			c2.growafter = Timer:new{
				timelimit = 1.5,
				funcToCall = function(timer)
					c2.sizeGrowth = 3
					timer:stop()
				end
			}

			self.healths[i] = bossTwo.maxhealth*.25
		end
	end
end

function bossTwo.behaviors.fourth( self )
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		local c1, c2 = t.circles[1], t.circles[2]
		if c1 then 
			c1.position:add(t.position):add(t.bossTwopos)
			if c1.size > 50 then c1.sizeGrowth = 0 c1.size = 50 end
		end
		if c2 then 
			c2.position:add(t.position):add(t.bossTwopos)
			if c2.size > 50 then c2.sizeGrowth = 0 c2.size = 50 end
		end
		if c1 or c2 then
			for _, s in pairs(Shot.bodies) do
				local c1c, c2c = s:collidesWith(c1), s:collidesWith(c2)
				local c = c1c and c1 or c2
				if c1c or c2c then
					c.size = max(c.size - 3, 5)
					if c.growafter.running then c.growafter.time = 0
					else c.growafter:start() end

					s.collides = true
					s.explosionEffects = true
				end
			end
		end
		if c1 then c1.position:sub(t.position):sub(t.bossTwopos) end
		if c2 then c2.position:sub(t.position):sub(t.bossTwopos) end
	end
	if self.health <= 0 then
		RecordsManager.addScore(750)
		self.redhealths = nil
		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			t.shoottimer:stop()
			t.target = t.position:normalized():mult(width/2 - 85, height/2 - 85)
			t.speed:set(t.target):sub(t.position):div(2, 2)
			t.onLocation = false
			t.prevdist = t.position:distsqr(t.target)
			local c1, c2 = t.circles[1], t.circles[2]
			if c1 then
				c1.position:add(t.position):add(t.bossTwopos)
				Effect.createEffects(c1, 30)
				t.circles[1] = nil
			end
			if c2 then
				c2.position:add(t.position):add(t.bossTwopos)
				Effect.createEffects(c2, 30)
				t.circles[2] = nil
			end
		end
		self.sizeGrowth = -10
		self.ballspeed = -20
		self.currentBehavior = bossTwo.behaviors.imploding
	end
end

function bossTwo.behaviors.imploding( self )
	if self.size < 50 then self.sizeGrowth = 0 self.size = 50 end
	if self.ballspos < 0 then self.ballspeed = 0 self.ballspos = 0 end
	if self.sizeGrowth ~= 0 or self.ballspeed ~= 0 or self.size ~= 50 or self.ballspos ~= 0 then return end
	for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end	end
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		t.lifecircle = CircleEffect:new{ alpha = 255, index = t, size = t.size, sizeGrowth = 35, position = t.position + self.position, linewidth = 5 }
		function t.lifecircle:update( dt )
			CircleEffect.update(self, dt)
			if self.size > t.size + 60 then self.sizeGrowth = 0 self.size = t.size + 60 t.shoottimer:start(t.shoottimer.timelimit) end
			if self.size < t.size then 
				self.delete = true 
				t.position:set(self.position) 
				Effect.createEffects(t, 100) 
				t.shoottimer:remove() 
				bossTwo.turrets[i] = nil
				for _, tur in pairs(bossTwo.turrets) do tur.shoottimer.timelimit = tur.shoottimer.timelimit/1.5 end
			end
		end
		t.update = Base.doNothing
	end
	self.currentBehavior = bossTwo.behaviors.turretprotection
end

function bossTwo.behaviors.turretprotection( self )
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t and t.lifecircle.sizeGrowth then
			for i,v in pairs(Shot.bodies) do
				if v:collidesWith(t.lifecircle) then
					t.lifecircle.size = t.lifecircle.size - 2
					v.collides = true
					v.explosionEffects = true
				end
			end
		end
	end
	for i = 1, 4 do if bossTwo.turrets[i] then return end end
	local a = VarTimer:new{}
	a:setAndGo(0, 255, 100)
	self.plead = Text:new{
		text = "Please don't kill me!",
		font = Base.getCoolFont(30),
		position = Vector:new{width/2 - 146, height/2 - 110},
		alphaFollows = a
	}
	self.plead:register()
	Timer:new{ timelimit = 4, onceOnly = true, running = true, funcToCall = function ()
		a:setAndGo(255, 0, 100)
	end}
	Timer:new{ timelimit = 1, onceOnly = true, running = true, funcToCall = function ()
		self.plead = nil
		self.ballscolors[4][1]:setAndGo(nil, 0, 100)
		self.ballscolors[4][2]:setAndGo(nil, 255, 100)
		self.ballscolors[4][3]:setAndGo(nil, 0, 100)
		self.currentBehavior = bossTwo.behaviors.final
	end}
	
	self.healths[1] = 100
	self.currentBehavior = Base.doNothing
end

function bossTwo.behaviors.final( self )
	if self.healths[1] < 100 then
		self.size = self.healths[1]/2
	end
	if self.size < 10 then
		RecordsManager.addScore(2000)
		self.delete = true
		Effect.createEffects(self, 100)
	end
end

function bossTwo:draw()
	local xt, yt = self.position:unpack()
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t then t:draw(xt, yt) end
	end
	local bp = self.ballspos
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballscoloreffects[1]))
	graphics.circle(self.mode, xt - bp, yt - bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballscoloreffects[2]))
	graphics.circle(self.mode, xt + bp, yt - bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballscoloreffects[3]))
	graphics.circle(self.mode, xt - bp, yt + bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballscoloreffects[4]))
	graphics.circle(self.mode, xt + bp, yt + bp, self.size)
end

function bossTwo:collides( v, n )
	return (v.size + self.size)^2 >= (v.x - self.x - (n%2==0 and 1 or -1)*self.ballspos)^2 + (v.y - self.y - (n>2 and 1 or -1)*self.ballspos)^2
end

function bossTwo:getShot()
	return (random() < .5 and Enemies.simpleball or Enemies.multiball):new{ score = false }
end

function bossTwo:update( dt )
	CircleEffect.update(self, dt)
	Body.update(self, dt)
	self:currentBehavior()
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t then t:update(dt) end
	end
	self.ballspos = self.ballspos + self.ballspeed*dt

	for i,v in pairs(Shot.bodies) do
		local c1, c2, c3, c4 = self:collides(v, 1), self:collides(v, 2), self:collides(v, 3), self:collides(v, 4)
		if c1 or c2 or c3 or c4 then
			local n = c1 and 1 or c2 and 2 or c3 and 3 or 4
			v.collides = true
			v.explosionEffects = true
			if self.healths[n] > 0 and self.vulnerable then 
				self.healths[n] = self.healths[n] - 1
				local d = self.healths[n]/bossTwo.maxhealth
				if self.currentBehavior == bossTwo.behaviors.arriving or self.currentBehavior == bossTwo.behaviors.first then
					d = (max(d,.75)-.75)*4
					local colors = self.ballscolors[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3] is already correct
						Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
							local colors = self.ballscolors[n]
							colors[1]:setAndGo(nil, (1-d)*255, 300)
							colors[2]:setAndGo(nil, d*120, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.second then
					d = (max(d,.5)-.5)*4
					local colors = self.ballscolors[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						colors[3]:setAndGo(0, 700)
						Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
							colors[1]:setAndGo(nil, (1-d)*255, 300)
							colors[2]:setAndGo(nil, d*50, 300)
							colors[3]:setAndGo(nil, d*140, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.third then
					d = (max(d,.25)-.25)*4
					local colors = self.ballscolors[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3]:setAndGo(0, 700)
						Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
							colors[1]:setAndGo(nil, 80 + (1-d)*(255 - 80), 300)
							colors[2]:setAndGo(nil, d*90, 300)
							--colors[3]:setAndGo(nil, d*255, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.fourth then
					self.healths[n] = max(self.healths[n] - 2, 0)
					d = self.healths[n]/bossTwo.maxhealth
					d = max(d,0)*4
					local colors = self.ballscolors[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3]:setAndGo(0, 700)
						Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
							colors[1]:setAndGo(nil, (1-d)*255, 300)
							colors[2]:setAndGo(nil, d*240, 300)
							--colors[3]:setAndGo(nil, d*255, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.final then
					self.healths[n] = self.healths[n] - 4
				end
			end
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and (self:collides(psycho, 1) or self:collides(psycho, 2) or self:collides(psycho, 3) or self:collides(psycho, 4)) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
end

function bossTwo:__index( key )
	if key == 'health' then return max(unpack(self.healths))
	else return bossTwo:__super().__index(self, key) end
end

bossTwo.turret = Body:new {
	size = 60,
	health = bossTwo.maxhealth/4,
	variance = random(ColorManager.colorCycleTime*1000)/1000,
	turretnum = 4,
	ballscoloreffect = ColorManager.getColorEffect(175, 0, 0, 40),
	coloreffect = ColorManager.noLSDEffect,
	attached = true,
	__type = 'bossTwoTurret'
}

Body.makeClass(bossTwo.turret)

function bossTwo.turret:__init()
	self.shoottimer = Timer:new {
		timelimit = 1.5,
		funcToCall = function ()
			local e = bossTwo:getTurretShot()
			e.position = (self.attached and self.position + self.bossTwopos or self.position:clone())
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(e.position)):normalize():mult(v, v)
			e:register()
		end
	}
	self.circles = {
		CircleEffect:new{ index = false, alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{0, -55}},
		CircleEffect:new{ index = false, alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{ 55, 0}},
		CircleEffect:new{ index = false, alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{0,  55}},
		CircleEffect:new{ index = false, alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{-55, 0}}
	}
	self.bossTwopos = Vector:new{}
end

function bossTwo.turret:draw( xt, yt )
	if self.attached then self.bossTwopos:set(xt, yt)
	else self.bossTwopos:set(0, 0) end
	local x, y = self.bossTwopos[1] + self.position[1], self.bossTwopos[2] + self.position[2]
	graphics.translate(x, y)
	for _, c in pairs(self.circles) do c:draw() end
	graphics.translate(-x,-y)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.coloreffect))
	graphics.circle(self.mode, x, y, self.size)
end

local auxVec = Vector:new{}

function bossTwo.turret:update( dt )
	Body.update(self, dt)

	for _, c in pairs(self.circles) do
		c:update(dt)
		c.position:add(auxVec:set(c.speed):mult(dt))
	end

	if not self.onLocation and self.target then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1 or curdist > self.prevdist then
			self.speed:reset()
			self.prevdist = nil
			self.onLocation = true
			self.target = nil
		else
			self.prevdist = curdist
		end
	end

	self.position:add(self.bossTwopos)
	for i,v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			if self.health > 0 then self.health = self.health - 1 end
			v.collides = true
			v.explosionEffects = true
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
	self.position:sub(self.bossTwopos)

	self.delete = self.delete --or self.health <= 0
end

function bossTwo.turret:detach( pos )
	if not self.attached then return end
	self.position:add(pos)
	self.attached = false
end

function bossTwo.turret:attach( pos )
	if self.attached then return end
	self.position:sub(pos)
	self.attached = true
end

function bossTwo.turret:handleDelete()
	self.shoottimer:remove()
	Effect.createEffects(self, 50)
	for _, tur in pairs(bossTwo.bodies) do
		tur.shoottimer.timelimit = tur.shoottimer.timelimit / 1.5
	end
	bossTwo.turretnum = bossTwo.turretnum - 1
end