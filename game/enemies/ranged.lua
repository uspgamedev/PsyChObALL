ranged = body:new {
	size =  30,
	divideN = 3,
	angle = 0,
	anglechange = nil,
	life = 5,
	timeout = 10,
	timeToShoot = 1,
	ord = 6,
	__type = 'ranged'
}

function ranged:__init()
	if not self.target then enemy.__init(self) end
	self.target = self.target or vector:new{math.random(width), math.random(height)}
	self.speed:set(self.target):sub(self.position):normalize():mult(1.3*v, 1.3*v)
	self.prevdist = self.position:distsqr(self.target)
	self.onLocation = false
	self.anglechange = self.anglechange or base.toRadians(360/self.divideN)
	self.shotcircle = circleEffect:new{
		coloreffect = self.shot.coloreffect,
		size = self.size + 4,
		position = self.position,
		index = false,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 5
	}
	self.timeout = timer:new {
		timelimit = self.timeout,
		onceonly = true,
		funcToCall = function()
			if self.shoottimer then self.shoottimer:stop() end
			self.speed:set(self.exitposition):sub(self.position):normalize():mult(1.3*v, 1.3*v)
		end
	}
end

function ranged:onInit( num, target, pos, exitpos, shot, initialcolor, angle, timeout)
	self.timeout = timeout
	self.angle = angle or 0
	self.basecolor = initialcolor or {0, 255, 0}
	self.colorvars = {vartimer:new{var = self.basecolor[1]}, vartimer:new{var = self.basecolor[2]}, vartimer:new{var = self.basecolor[3]}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(unpack(self.colorvars))
	self.divideN = num or self.divideN
	self.shot = shot and enemies[shot] or enemies.simpleball
	if not pos then enemy.__init(self)
	else self.position = base.clone(pos) end
	self.exitposition = base.clone(exitpos) or self.position:clone()
	self.target = base.clone(target)
end

function ranged:start()
	body.start(self)
	circleEffect.bodies[self] = self.shotcircle
end

function ranged:update( dt )
	body.update(self, dt)

	if not self.onLocation then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1  or curdist > self.prevdist then
			self.timeout:start()
			self.speed:reset()
			self.onLocation = true
			self.prevdist = nil
			self.shoottimer = timer:new {
				timelimit  = self.timeToShoot,
				running = true,
				funcToCall = function() self:shoot() end
			}
		else
			self.prevdist = curdist
		end
	end

	for _, v in pairs(shot.bodies) do
		if self:collidesWith(v) then
			self.life = self.life - 1
			self.colorvars[1].var = self.basecolor[1] - ((ranged.life - self.life) / ranged.life) * (self.basecolor[1] - 255)
			self.colorvars[2].var = self.basecolor[2] - ((ranged.life - self.life) / ranged.life) * self.basecolor[2]
			self.colorvars[3].var = self.basecolor[3] - ((ranged.life - self.life) / ranged.life) * self.basecolor[3]
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.life == 0
end

function ranged:shoot()
	local ang = self.angle + base.toRadians(180)
	local speed = self.setspeed or 1.5*v
	for i = 1, self.divideN do
		local e = self.shot:new{}
		e.position = self.position:clone()
		e.speed = vector:new{math.sin(ang)*speed, math.cos(ang)*speed}
		ang = ang + self.anglechange
		e:register()
	end
end

function ranged:handleDelete()
	body.handleDelete(self)
	neweffects(self, 30)
	self.shotcircle.size = -1
	self.timeout:remove()
	if self.diereason == "shot" then
		addscore(25*self.divideN)
		self.divideN = self.divideN + 3	
		self.anglechange = base.toRadians(360/self.divideN)
		self:shoot()
	end
	if self.shoottimer then self.shoottimer:remove() end
end