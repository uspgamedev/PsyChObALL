local random, sin, cos, arctan, abs = math.random, math.sin, math.cos, math.atan2, math.abs

bossOne = CircleEffect:new {
	size = 80,
	maxhealth = 160,
	basespeed = 2*v,
	basespeedsqrt = math.sqrt(2*v),
	index = false,
	alpha = 255,
	mode = 'fill',
	spriteBatch = false,
	sizeGrowth = 0,
	shader = Base.circleShader,
	maxsize = width,
	ord = 7,
	__type = 'bossOne'
}

Body.makeClass(bossOne)

function bossOne:__init()
	self.position:set(-self.size, -self.size)
	self.speed:set(v, v)
	self.currentBehavior = bossOne.behaviors.arriving
	self.health = bossOne.maxhealth
	self.variance = random((ColorManager.colorCycleTime-3)*1000)/1000 + 3
	bossOne.shot = Enemies.simpleball
	bossOne.prevdist = self.position:distsqr(self.size + 10, self.size + 10)
	self.colors = {VarTimer:new{var = 0xFF, speed = 200}, VarTimer:new{var = 0xFF, speed = 200}, VarTimer:new{var = 0, speed = 200}}
	self.coloreffect = ColorManager.getColorEffect(self.colors[1], self.colors[2], self.colors[3], 30)
	self.restrictToScreenThreshold = 10
	restrictToScreenSpeed = nil
	--bossOne.turret.bodies = Enemies.bossOne.bodies
end

bossOne.behaviors = {}
function bossOne.behaviors.arriving( self )
	local curdist = self.position:distsqr(self.size + 10, self.size + 10)
	if curdist < 1 or curdist > self.prevdist then
		self.position:set(self.size + 10, self.size + 10)
		self.speed:set(bossOne.basespeed, 0)
		self.speedchange = Timer:new {
			timelimit = 5 + random()*10,
			running = true,
			funcToCall = function(timer )
				timer.timelimit = 5 + random()*10
				self.speed:negate()
			end
		}
		self.shoottimer = Timer:new {
			timelimit = .5,
			works_on_gameLost = false,
			time = random(),
			running = true
		}

		function self.shoottimer.funcToCall()
			local e = self:getShot()
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = pos:sub(self.position):normalize():mult(2 * v, 2 * v):rotate((random()-.5)*Base.toRadians(15))
			e:register()
		end

		function self:getShot()
			return (random() > .5 and Enemies.simpleball or Enemies.multiball):new{ score = false }
		end

		self.currentBehavior = bossOne.behaviors.first
	end
	self.prevdist = curdist
end

function bossOne.behaviors.first( self )
	self:restrictToScreen()
	if self.health/bossOne.maxhealth < .75 then
		RecordsManager.addScore(500)
		local t = ImageBody:new{ coloreffect = ColorManager.sinCityEffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
		Enemy.__init(t)
		t.speed:mult(2.2)
		t:register()
		self.currentBehavior = bossOne.behaviors.second
		self.speedchange:remove()
		self.speedchange = nil
		self.health = bossOne.maxhealth * .75
		function self:getShot()
			return Enemies.multiball:new{ score = false }
		end
		self.colors[1]:setAndGo(nil, 0, 122)
		self.colors[2]:setAndGo(nil, 255, 122)
		self.colors[3]:setAndGo(nil, 0, 122)
	end
end

function bossOne.behaviors.second( self )
	local mx, my = self:restrictToScreen()
	if mx and random() < .43 then 
		self.speed:set(mx * (width - 2*self.size - 20), my * (height - 2*self.size - 20)):normalize():mult(bossOne.basespeed)
	end
	if self.health/bossOne.maxhealth < .5 then
		RecordsManager.addScore(500)
		self.speed:set(width/2, height/2):sub(self.position):normalize():mult(bossOne.basespeed)
		self.currentBehavior = bossOne.behaviors.toTheMiddle
		self.prevdist = self.position:distsqr(width/2, height/2)
		self.health = bossOne.maxhealth * .5
	end
end

function bossOne.behaviors.toTheMiddle( self )
	local curdist = self.position:distsqr(width/2, height/2)
	if curdist < 1 or curdist > self.prevdist then
		self.position:set(width/2, height/2)
		self.speed:set(0,0)
		self.currentBehavior = bossOne.behaviors.third
		self.shoottimer.timelimit = 8
		self.shoottimer.time = 5
		bossOne.shot = Enemies.simpleball
		function self.shoottimer.funcToCall()
			local side = random() < .5 and -1 or 1
			self.circleshoot.angle = arctan(psycho.x - self.x, psycho.y - self.y)  + side*Base.toRadians(30)
			self.circleshoot.anglechange = -abs(self.circleshoot.anglechange)*side
			self.circleshoot.timescount = 0
			self.circleshoot:start(self.circleshoot.timelimit)
		end
		self.circleshoot = Timer:new {
			timelimit = .07,
			anglechange = Base.toRadians(6),
			times = 100,
			angle = 0,
			works_on_gameLost = false,
			time = random()*2
		}
		function self.circleshoot.funcToCall(timer)
			local e = self:getShot()
			e.position = self.position + {sin(timer.angle)*(bossOne.size-e.size), cos(timer.angle)*(bossOne.size-e.size)}
			e.speed:set(
				bossOne.basespeed * sin(timer.angle),
				bossOne.basespeed * cos(timer.angle))
			e:register()
			timer.angle = timer.angle + timer.anglechange
			timer.timescount = timer.timescount + 1
			if timer.timescount >= timer.times then 
				timer:stop()
			end
		end
		self.colors[1]:setAndGo(nil, 0, 122)
		self.colors[2]:setAndGo(nil, 255, 122)
		self.colors[3]:setAndGo(nil, 255, 122)
	end
	self.prevdist = curdist
end

function bossOne.behaviors.third( self )
	if self.health/bossOne.maxhealth <= .075 then
		RecordsManager.addScore(500)
		self.health = bossOne.maxhealth * .075
		self.shoottimer:remove()
		self.shoottimer:funcToCall()
		self.circleshoot:remove()
		self.circleshoot.anglechange = Base.toRadians(15)
		self.circleshoot.times = 360/15
		bossOne.shot = Enemies.simpleball
		--change color or whatever
		self.coloreffect = ColorManager.sinCityEffect
		Timer:new {
			running = true,
			onceOnly = true,
			timelimit = 1,
			funcToCall = function() self.sizeGrowth = 230 end
		}
		self.currentBehavior = bossOne.behaviors.toExplode
	end
end

function bossOne.behaviors.toExplode( self )
	if self.size > width/2 + 100 or self.health <= 0 then
		RecordsManager.addScore(500)
		self.sizeGrowth = -1300
	end
end

function bossOne:restrictToScreen()
	local th = self.restrictToScreenThreshold
	local sp = self.restrictToScreenSpeed or bossOne.basespeed
	if self.x > width - th - self.size then
		self.x = width - th - self.size
		self.speed:set(0, self.y > height/2 and -sp or sp)
		return -1, Base.sign(self.Vy)
	elseif self.x < self.size + th then
		self.x = self.size + th
		self.speed:set(0, self.y > height/2 and -sp or sp)
		return 1, Base.sign(self.Vy)
	elseif self.y > height - th - self.size then
		self.y = height - th - self.size
		self.speed:set(self.x > width/2 and -sp or sp, 0)
		return Base.sign(self.Vx), -1
	elseif self.y < self.size + th then
		self.y = self.size + th
		self.speed:set(self.x > width/2 and -sp or sp, 0)
		return Base.sign(self.Vx), 1
	end
end

function bossOne:update( dt )
	CircleEffect.update(self, dt)
	Body.update(self, dt)
	self:currentBehavior()

	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			v.collides = true
			v.explosionEffects = true
			if self.health > 0 then 
				self.health = self.health - 1
				local d = self.health/bossOne.maxhealth
				if self.currentBehavior == bossOne.behaviors.first or self.currentBehavior == bossOne.behaviors.arriving then
					d = (math.max(d,.75)-.75)*4
					--self.colors[1] is already correct
					self.colors[2]:setAndGo(nil, 0, 1200)
					--self.colors[3] is already correct
					Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossOne.behaviors.first or self.currentBehavior == bossOne.behaviors.arriving then
							self.colors[2]:setAndGo(nil, d*255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossOne.behaviors.second then
					d = (math.max(d,.5)-.5)*4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					--self.colors[3] is already correct
					Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossOne.behaviors.second then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[2]:setAndGo(nil, d*255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossOne.behaviors.third or self.currentBehavior == bossOne.behaviors.toTheMiddle then
					d = (math.max(d,.075)-.075)/(.5 - .075)
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossOne.behaviors.third or self.currentBehavior == bossOne.behaviors.toTheMiddle then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[2]:setAndGo(nil, d*255, 400)
							self.colors[3]:setAndGo(nil, d*255, 400)
						end
					end
					}
				end
			end
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
end

bossOne.draw = Base.defaultDraw

function bossOne:handleDelete()
	self.size = 1
	Effect.createEffects(self, 300)
	self.size = 0
end