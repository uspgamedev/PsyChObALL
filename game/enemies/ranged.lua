ranged = body:new {
	size =  30,
	divideN = 3,
	angle = 0,
	anglechange = nil,
	life = 5,
	__type = 'ranged'
}

function ranged:__init()
	if not self.target then enemy.__init(self) end
	self.target = self.target or vector:new{math.random(width), math.random(height)}
	self.speed:set(self.target):sub(self.position):normalize():mult(1.3*v, 1.3*v)
	self.prevdist = self.position:distsqr(self.target)
	self.onLocation = false
	self.anglechange = self.anglechange or torad(360/self.divideN)
	self.shotcircle = circleEffect:new{
		coloreffect = self.shot.coloreffect,
		size = self.size,
		position = self.position,
		index = false,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 10
	}
end

function ranged:onInit( num, target, shot, initialcolor, angle )
	self.angle = angle or 0
	self.basecolor = initialcolor or {0, 255, 0}
	self.colorvars = {vartimer:new{var = self.basecolor[1]}, vartimer:new{var = self.basecolor[2]}, vartimer:new{var = self.basecolor[3]}}
	self.coloreffect = getColorEffect(unpack(self.colorvars))
	self.divideN = num or self.divideN
	self.shot = shot and enemies[shot] or enemies.simpleball
	if target then
		enemy.__init(self)
		self.target = target:clone()
	end
end

function ranged:start()
	circleEffect.bodies[self] = self.shotcircle
end

function ranged:update( dt )
	body.update(self, dt)

	if not self.onLocation then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1  or curdist > self.prevdist then
			self.speed:reset()
			self.onLocation = true
			self.prevdist = nil
			self.shoottimer = timer:new {
				timelimit  = 1,
				running = true,
				funcToCall = function() self:shoot() end
			}
		else
			self.prevdist = curdist
		end
	end

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size)^2 >= (v.x - self.x)^2 + (v.y - self.y)^2 then
			self.life = self.life - 1
			self.colorvars[1].var = self.basecolor[1] - ((ranged.life - self.life) / ranged.life) * (self.basecolor[1] - 255)
			self.colorvars[2].var = self.basecolor[2] - ((ranged.life - self.life) / ranged.life) * self.basecolor[2]
			self.colorvars[3].var = self.basecolor[3] - ((ranged.life - self.life) / ranged.life) * self.basecolor[3]
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
		end
	end

	if psycho.canbehit and not gamelost and (psycho.size + self.size)^2 >= (psycho.x - self.x)^2 + (psycho.y - self.y)^2 then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.life == 0
end

function ranged:shoot()
	local ang = self.angle + torad(180)
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
	neweffects(self, 30)
	self.shotcircle.size = -1
	self.divideN = self.divideN + 3	
	self.anglechange = torad(360/self.divideN)
	self:shoot()
	if self.shoottimer then self.shoottimer:remove() end
end