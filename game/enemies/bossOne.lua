local random, sin, cos, arctan, abs = math.random, math.sin, math.cos, math.atan2, math.abs

bossOne = CircleEffect:new {
	size = 80,
	maxhealth = 160,
	basespeed = 2*v,
	basespeedsqrt = math.sqrt(2*v),
	alpha = 255,
	mode = 'fill',
	sizeGrowth = 0,
	shader = Base.circleShader,
	maxSize = width,
	ord = 7,
	__type = 'bossOne'
}

Body.makeClass(bossOne)

function bossOne:revive()
	CircleEffect.revive(self)

	self.sizeGrowth = bossOne.sizeGrowth
	self.size = bossOne.size
	self.mode = bossOne.mode
	self.alpha = bossOne.alpha

	self.position:set(-self.size, -self.size)
	self.speed:set(v, v)
	self.currentBehavior = bossOne.behaviors.arriving
	self.health = bossOne.maxhealth
	self.variance = random() * (ColorManager.colorCycleTime - 6) + 3

	bossOne.shot = Enemies.simpleball
	bossOne.prevdist = self.position:distsqr(self.size + 10, self.size + 10)

	self.colors = {VarTimer:new{var = 0xFF, speed = 200}, VarTimer:new{var = 0xFF, speed = 200}, VarTimer:new{var = 0, speed = 200}}
	self.coloreffect = ColorManager.getColorEffect(self.colors[1], self.colors[2], self.colors[3], 30)
	self.restrictToScreenThreshold = 10
	
	restrictToScreenSpeed = nil

	return self
end

bossOne.behaviors = {}
function bossOne.behaviors.arriving( self )
	local curdist = self.position:distsqr(self.size + 10, self.size + 10)
	if curdist < 1 or curdist > self.prevdist then
		self.position:set(self.size + 10, self.size + 10)
		self.speed:set(bossOne.basespeed, 0)
		self.speedchange = Timer:new {
			timeLimit = 5 + random()*10,
			running = true,
			callback = function(timer )
				timer.timeLimit = 5 + random()*10
				self.speed:negate()
			end
		}
		self.shoottimer = Timer:new {
			timeLimit = .5,
			worksOnGameLost = false,
			time = random(),
			running = true
		}

		function self.shoottimer.callback()
			local e = self:getShot()
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = pos:sub(self.position):normalize():mult(2 * v, 2 * v):rotate((random()-.5)*Base.toRadians(15))
			e:register()
		end

		function self:getShot()
			return Body.reviveAndCopy((random() > .5 and Enemies.simpleball or Enemies.multiball).bodies:getFirstAvailable(), { score = false })
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
		function self:getShot() return Body.reviveAndCopy(Enemies.multiball.bodies:getFirstAvailable(), { score = false }) end
		
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
		self.shoottimer.timeLimit = 8
		self.shoottimer.time = 5
		bossOne.shot = Enemies.simpleball
		function self.shoottimer.callback()
			local side = random() < .5 and -1 or 1
			self.circleshoot.angle = arctan(psycho.x - self.x, psycho.y - self.y)  + side*Base.toRadians(30)
			self.circleshoot.angleDelta = -abs(self.circleshoot.angleDelta)*side
			self.circleshoot.timescount = 0
			self.circleshoot:start(self.circleshoot.timeLimit)
		end
		self.circleshoot = Timer:new {
			timeLimit = .07,
			angleDelta = Base.toRadians(6),
			times = 100,
			angle = 0,
			worksOnGameLost = false,
			time = random()*2
		}
		function self.circleshoot.callback(timer)
			local e = self:getShot()
			e.position = self.position + {sin(timer.angle)*(bossOne.size-e.size), cos(timer.angle)*(bossOne.size-e.size)}
			e.speed:set(
				bossOne.basespeed * sin(timer.angle),
				bossOne.basespeed * cos(timer.angle))
			e:register()
			timer.angle = timer.angle + timer.angleDelta
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
		self.shoottimer:callback()
		self.circleshoot:remove()
		self.circleshoot.angleDelta = Base.toRadians(15)
		self.circleshoot.times = 360/15
		bossOne.shot = Enemies.simpleball
		--change color or whatever
		self.coloreffect = ColorManager.sinCityEffect
		Timer:new {
			running = true,
			onceOnly = true,
			timeLimit = 1,
			callback = function() self.sizeGrowth = 230 end
		}
		self.currentBehavior = bossOne.behaviors.toExplode
	end
end

function bossOne.behaviors.toExplode( self )
	if self.size > width/2 + 100 or self.health <= 0 then
		RecordsManager.addScore(1000)
		self.sizeGrowth = -1300
		self.currentBehavior = Base.doNothing
	end
end

function bossOne.restrictToScreen( obj )
	-- keep on screen
	local th = obj.restrictToScreenThreshold
	local sp = obj.restrictToScreenSpeed or bossOne.basespeed

	if obj.x > width - th - obj.size then
		obj.x = width - th - obj.size
		obj.speed:set(0, obj.y > height/2 and -sp or sp)
		return -1, Base.sign(obj.Vy)
	elseif obj.x < obj.size + th then
		obj.x = obj.size + th
		obj.speed:set(0, obj.y > height/2 and -sp or sp)
		return 1, Base.sign(obj.Vy)
	elseif obj.y > height - th - obj.size then
		obj.y = height - th - obj.size
		obj.speed:set(obj.x > width/2 and -sp or sp, 0)
		return Base.sign(obj.Vx), -1
	elseif obj.y < obj.size + th then
		obj.y = obj.size + th
		obj.speed:set(obj.x > width/2 and -sp or sp, 0)
		return Base.sign(obj.Vx), 1
	end
end

local max = math.max
function bossOne:update( dt )
	CircleEffect.update(self, dt)
	Body.update(self, dt)
	self:currentBehavior()

	Shot.bodies:forEachAlive(function(shot)
		if self.alive and self:collidesWith(shot) then
			shot.explosionEffects = true
			shot:kill()

			if self.health > 0 then 
				self.health = self.health - 1
				local d = self.health/bossOne.maxhealth
				if self.currentBehavior == bossOne.behaviors.first or self.currentBehavior == bossOne.behaviors.arriving then
					d = (max(d,.75)-.75)*4
					--self.colors[1] is already correct
					self.colors[2]:setAndGo(nil, 0, 1200)
					--self.colors[3] is already correct
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						if self.currentBehavior == bossOne.behaviors.first or self.currentBehavior == bossOne.behaviors.arriving then
							self.colors[2]:setAndGo(nil, d*255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossOne.behaviors.second then
					d = (max(d,.5)-.5)*4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					--self.colors[3] is already correct
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						if self.currentBehavior == bossOne.behaviors.second then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[2]:setAndGo(nil, d*255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossOne.behaviors.third or self.currentBehavior == bossOne.behaviors.toTheMiddle then
					d = (max(d,.075)-.075)/(.5 - .075)
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
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
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

bossOne.draw = Base.defaultDraw

function bossOne:kill()
	Body.kill(self)

	self.size = 1
	Effect.createEffects(self, 300)
	self.size = 0
end