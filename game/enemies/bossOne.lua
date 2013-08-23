bossOne = circleEffect:new {
	size = 80,
	maxhealth = 160,
	basespeed = 2*v,
	basespeedsqrt = math.sqrt(2*v),
	index = false,
	alpha = 255,
	mode = 'fill',
	changesimage = true,
	sizeGrowth = 0,
	maxsize = width,
	ord = 7,
	__index = circleEffect.__index,
	__newindex = circleEffect.__newindex,
	__type = 'bossOne'
}

function bossOne:__init()
	self.position:set(-self.size, -self.size)
	self.speed:set(v, v)
	self.currentBehavior = bossOne.behaviors.arriving
	self.health = bossOne.maxhealth
	self.variance = math.random((ColorManager.cycleTime-3)*1000)/1000 + 3
	bossOne.shot = enemies.simpleball
	bossOne.prevdist = self.position:distsqr(self.size + 10, self.size + 10)
	self.colors = {vartimer:new{var = 0xFF, speed = 200}, vartimer:new{var = 0xFF, speed = 200}, vartimer:new{var = 0, speed = 200}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(self.colors[1], self.colors[2], self.colors[3], 30)
	restrictToScreenThreshold = 10
	restrictToScreenSpeed = nil
	--bossOne.turret.bodies = enemies.bossOne.bodies
end

bossOne.behaviors = {}
function bossOne.behaviors.arriving( self )
	local curdist = self.position:distsqr(self.size + 10, self.size + 10)
	if curdist < 1 or curdist > self.prevdist then
		self.position:set(self.size + 10, self.size + 10)
		self.speed:set(bossOne.basespeed, 0)
		self.speedchange = timer:new {
			timelimit = 5 + math.random()*10,
			running = true,
			funcToCall = function( timer )
				timer.timelimit = 5 + math.random()*10
				self.speed:negate()
			end
		}
		self.shoottimer = timer:new {
			timelimit = .5,
			works_on_gamelost = false,
			time = math.random(),
			running = true
		}

		function self.shoottimer.funcToCall()
			local e = (math.random() > .5 and enemies.simpleball or enemies.multiball):new{}
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = pos:sub(self.position):normalize():mult(2 * v, 2 * v):rotate((math.random()-.5)*torad(15))
			e:register()
		end
		self.currentBehavior = bossOne.behaviors.first
	end
	self.prevdist = curdist
end

function bossOne.behaviors.first( self )
	self:restrictToScreen()
	if self.health/bossOne.maxhealth < .75 then
		addscore(500)
		local t = imagebody:new{ coloreffect = ColorManager.sinCityEffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
		enemy.__init(t)
		t.speed:mult(2.2)
		t:register()
		self.currentBehavior = bossOne.behaviors.second
		self.speedchange:remove()
		self.speedchange = nil
		self.health = bossOne.maxhealth * .75
		function self.shoottimer.funcToCall()
			local e = (enemies.multiball):new{}
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = pos:sub(self.position):normalize():mult(2 * v, 2 * v):rotate((math.random()-.5)*torad(15))
			e:register()
		end
		self.colors[1]:setAndGo(nil, 0, 122)
		self.colors[2]:setAndGo(nil, 255, 122)
		self.colors[3]:setAndGo(nil, 0, 122)
	end
end

function bossOne.behaviors.second( self )
	local mx, my = self:restrictToScreen()
	if mx and math.random() < .43 then 
		self.speed:set(mx * (width - 2*self.size - 20), my * (height - 2*self.size - 20)):normalize():mult(bossOne.basespeed)
	end
	if self.health/bossOne.maxhealth < .5 then
		addscore(500)
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
		bossOne.shot = enemies.simpleball
		function self.shoottimer.funcToCall()
			local side = math.random() < .5 and -1 or 1
			self.circleshoot.angle = math.atan2(psycho.x - self.x, psycho.y - self.y)  + side*torad(30)
			self.circleshoot.anglechange = -math.abs(self.circleshoot.anglechange)*side
			self.circleshoot.timescount = 0
			self.circleshoot:start(self.circleshoot.timelimit)
		end
		self.circleshoot = timer:new {
			timelimit = .07,
			anglechange = torad(6),
			times = 100,
			angle = 0,
			works_on_gamelost = false,
			time = math.random()*2
		}
		function self.circleshoot.funcToCall(timer)
			local e = enemies.multiball:new{}
			e.position = self.position + {math.sin(timer.angle)*(bossOne.size-e.size), math.cos(timer.angle)*(bossOne.size-e.size)}
			e.speed:set(
				bossOne.basespeed * math.sin(timer.angle),
				bossOne.basespeed * math.cos(timer.angle))
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
		addscore(500)
		self.health = bossOne.maxhealth * .075
		self.shoottimer:remove()
		self.shoottimer:funcToCall()
		self.circleshoot:remove()
		self.circleshoot.anglechange = torad(15)
		self.circleshoot.times = 360/15
		bossOne.shot = enemies.simpleball
		--change color or whatever
		self.coloreffect = ColorManager.sinCityEffect
		timer:new {
			running = true,
			onceonly = true,
			timelimit = 1,
			funcToCall = function() self.sizeGrowth = 230 end
		}
		self.currentBehavior = bossOne.behaviors.toExplode
	end
end

function bossOne.behaviors.toExplode( self )
	if self.size > width/2 + 100 or self.health <= 0 then
		addscore(500)
		self.sizeGrowth = -1300
	end
end

restrictToScreenThreshold = 10
restrictToScreenSpeed = nil
function bossOne:restrictToScreen()
	local th = restrictToScreenThreshold
	local sp = restrictToScreenSpeed or bossOne.basespeed
	if self.x > width - th - self.size then
		self.x = width - th - self.size
		self.speed:set(0, self.y > height/2 and -sp or sp)
		return -1, sign(self.Vy)
	elseif self.x < self.size + th then
		self.x = self.size + th
		self.speed:set(0, self.y > height/2 and -sp or sp)
		return 1, sign(self.Vy)
	elseif self.y > height - th - self.size then
		self.y = height - th - self.size
		self.speed:set(self.x > width/2 and -sp or sp, 0)
		return sign(self.Vx), -1
	elseif self.y < self.size + th then
		self.y = self.size + th
		self.speed:set(self.x > width/2 and -sp or sp, 0)
		return sign(self.Vx), 1
	end
end

function bossOne:update( dt )
	circleEffect.update(self, dt)
	body.update(self, dt)
	self:currentBehavior()

	for _, v in pairs(shot.bodies) do
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
					timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
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
					timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
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
					timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
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

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function bossOne:handleDelete()
	self.size = 1
	neweffects(self, 300)
	self.size = 0
end