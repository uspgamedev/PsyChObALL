bossOne = circleEffect:new {
	size = 80,
	maxhealth = 120,
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
	self.variance = math.random((colorcycle-3)*1000)/1000 + 3
	bossOne.shot = enemies.simpleball
	--bossOne.turret.bodies = enemies.bossOne.bodies
end

bossOne.behaviors = {}
function bossOne.behaviors.arriving( self )
	if self.position:distsqr(self.size + 10, self.size + 10) < 5 then
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
			local e = bossOne.shot:new{}
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(self.position)):normalize():add(math.random()/10, math.random()/10):normalize():mult(2 * v, 2 * v)
			e:register()
		end
		self.currentBehavior = bossOne.behaviors.first
	end
end
function bossOne.behaviors.first( self )
	self:restrictToScreen()
	if self.health/bossOne.maxhealth < .75 then 
		self.currentBehavior = bossOne.behaviors.second
		self.speedchange:remove()
		self.speedchange = nil
		--self.shot = divide1
	end
end

function bossOne.behaviors.second( self )
	local mx, my = self:restrictToScreen()
	if mx and math.random() < .43 then 
		self.speed:set(mx * (width - 2*self.size - 20), my * (height - 2*self.size - 20)):normalize():mult(bossOne.basespeed)
	end
	if self.health/bossOne.maxhealth < .5 then
		self.speed:set(vector:new{width/2, height/2}:sub(self.position)):normalize():mult(bossOne.basespeed)
		self.currentBehavior = bossOne.behaviors.toTheMiddle
	end
end

function bossOne.behaviors.toTheMiddle( self )
	if self.position:distsqr(width/2, height/2) < 5 then
		self.position:set(width/2, height/2)
		self.speed:set(0,0)
		self.currentBehavior = bossOne.behaviors.third
		self.shoottimer.timelimit = 7 
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
			local e = bossOne.shot:new{}
			e.position = self.position:clone()
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
	end
end

function bossOne.behaviors.third( self )
	if self.health == 0 then
		self.shoottimer:remove()
		self.shoottimer:funcToCall()
		self.circleshoot:remove()
		self.circleshoot.anglechange = torad(15)
		self.circleshoot.times = 360/15
		bossOne.shot = enemies.simpleball
		--change color or whatever
		self.coloreffect = sincityeffect
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
	if self.size >= width/2 - 50 then
		self.sizeGrowth = -1300
		--[[local old = bossOne.basespeed
		bossOne.basespeed = bossOne.basespeed / 1.3
		for i = 1, self.circleshoot.times do
			self.circleshoot:funcToCall()
		end
		bossOne.basespeed = old
		self.circleshoot = nil
		--create turrets
		local c = vector:new{width/2, height/2} --screen center
		bossOne.turret:new { position = c:clone(), speed = vector:new{v/2,  0} }:register()
		bossOne.turret:new { position = c:clone(), speed = vector:new{-v/2, 0} }:register()
		bossOne.turret:new { position = c:clone(), speed = vector:new{0,  v/2} }:register()
		bossOne.turret:new { position =         c, speed = vector:new{0, -v/2} }:register()
		bossOne.turret.count = 0
		bossOne.turretnum = 4]]

		--explode
		--self.delete = true
	end
end

function bossOne:restrictToScreen()
	if self.x > width - 10 - self.size then
		self.x = width - 10 - self.size
		self.speed:set(0, self.y > height/2 and -bossOne.basespeed or bossOne.basespeed)
		return -1, sign(self.Vy)
	elseif self.x < self.size + 10 then
		self.x = self.size + 10
		self.speed:set(0, self.y > height/2 and -bossOne.basespeed or bossOne.basespeed)
		return 1, sign(self.Vy)
	elseif self.y > height - 10 - self.size then
		self.y = height - 10 - self.size
		self.speed:set(self.x > width/2 and -bossOne.basespeed or bossOne.basespeed, 0)
		return sign(self.Vx), -1
	elseif self.y < self.size + 10 then
		self.y = self.size + 10
		self.speed:set(self.x > width/2 and -bossOne.basespeed or bossOne.basespeed, 0)
		return sign(self.Vx), 1
	end
end

function bossOne:update( dt )
	circleEffect.update(self, dt)
	body.update(self, dt)
	self:currentBehavior()

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			if self.health > 0 then self.health = self.health - 1 end
			v.collides = true
			v.explosionEffects = true
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function bossOne:handleDelete()
	self.size = 1
	neweffects(self, 300)
	self.size = 0
end

--[[
bossOne.turret = body:new {
	size = 50,
	health = bossOne.maxhealth/4,
	variance = math.random(colorcycle*1000)/1000,
	turretnum = 4,
	__type = 'bossOneTurret'
}

function bossOne.turret:__init( ... )
	self.shoottimer = timer:new {
		timelimit = 1.5,
		funcToCall = function ()
			local e = bossOne.shot:new{}
			e.position = self.position:clone()
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(self.position)):normalize():mult(v, v)
			e:register()
		end
	}
end

function bossOne.turret:update( dt )
	body.update(self, dt)
	if not self.speed:equals(0,0) and bossOne.restrictToScreen(self) then
		self.speed:set(0,0)
		bossOne.turret.count = bossOne.turret.count + 1
		if bossOne.turret.count == bossOne.turretnum then
			for _, tur in pairs(bossOne.bodies) do tur.shoottimer:start(1) end
		end
	end

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			if self.health > 0 then self.health = self.health - 1 end
			v.collides = true
			v.explosionEffects = true
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.health <= 0
end

function bossOne.turret:handleDelete()
	self.shoottimer:remove()
	neweffects(self, 50)
	for _, tur in pairs(bossOne.bodies) do
		tur.shoottimer.timelimit = tur.shoottimer.timelimit / 1.5
	end
	bossOne.turretnum = bossOne.turretnum - 1
end]]