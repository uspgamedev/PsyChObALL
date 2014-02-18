ranged = Body:new {
	size =  30,
	divideN = 3,
	angle = 0,
	angleDelta = nil,
	life = 5,
	timeOut = 10,
	timeToShoot = 1,
	shader = Base.circleShader,
	ord = 6,
	__type = 'ranged'
}

Body.makeClass(ranged)

local random = math.random
function ranged:revive( num, target, pos, exitpos, shot, initialcolor, angle, timeOut )
	Body.revive(self)

	self.timeOut = timeOut or ranged.timeOut
	self.angle = angle or ranged.angle
	self.baseColor = initialcolor or {0, 255, 0}
	self.colors = {VarTimer:new{var = self.baseColor[1]}, VarTimer:new{var = self.baseColor[2]}, VarTimer:new{var = self.baseColor[3]}}
	self.coloreffect = ColorManager.getColorEffect(unpack(self.colors))
	self.divideN = num or ranged.divideN

	self.shot = shot and Enemies[shot] or Enemies.simpleball
	if not pos then Enemy.randomizePosition(self)
	else self.position:set(pos) end
	self.exitPosition = Base.clone(exitpos) or self.position:clone()
	self.target = Base.clone(target) or Vector:new{.1 * width + random() * .8 * width, .1 * height + random() * .8 * height}

	self.shootCircle = CircleEffect.bodies:getFirstAvailable():revive()
	self.shootCircle.coloreffect = self.shot.coloreffect
	self.shootCircle.size = self.size + 4
	self.shootCircle.position = self.position -- YES HTE EXACT SAME
	self.shootCircle.sizeGrowth = 0
	self.shootCircle.alpha = 255
	self.shootCircle.linewidth = 5

	self.timeOutTimer = Timer:new {
		timelimit = self.timeOut,
		running = false,
		onceOnly = true,
		funcToCall = function()
			self.shootTimer:stop()
			self.speed:set(self.exitPosition):sub(self.position):normalize():mult(1.3 * v, 1.3 * v)
		end
	}

	self.shootTimer = Timer:new {
		timelimit  = ranged.timeToShoot,
		running = false,
		funcToCall = function() self:shoot() end
	}

	return self
end

function ranged:activate()
	Body.activate(self)
	self.shootCircle:activate()
end

function ranged:deactivate()
	Body.deactivate(self)
	self.shootCircle:deactivate()
end

function ranged:start()
	Body.start(self)
	
	self.shootCircle:register()

	self.angleDelta = Base.toRadians(360 / self.divideN)
	self.speed:set(self.target):sub(self.position):normalize():mult(1.3 * v, 1.3 * v)
	self.prevdist = self.position:distsqr(self.target)
	self.onLocation = false
end

ranged.draw = Base.defaultDraw

function ranged:update( dt )
	Body.update(self, dt)

	if not self.onLocation then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1  or curdist > self.prevdist then
			self.timeOutTimer:start()
			self.speed:set(0, 0)
			self.onLocation = true
			self.prevdist = nil
			self.shootTimer:start(-.5)
		else
			self.prevdist = curdist
		end
	end

	Shot.bodies:forEachAlive(function( shot )
		if self.alive and self:collidesWith(shot) then
			self:manageShotCollision(shot)
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

function ranged:manageShotCollision( shot )
	shot.explosionEffects = false
	shot:kill()

	self.life = self.life - 1
	if self.life == 0 then
		self.causeOfDeath = shot.isUltraShot and 'ultrashot' or 'shot'
		self:kill()
	end	

	self.colors[1].var = self.baseColor[1] - ((ranged.life - self.life) / ranged.life) * (self.baseColor[1] - 255)
	self.colors[2].var = self.baseColor[2] - ((ranged.life - self.life) / ranged.life) * self.baseColor[2]
	self.colors[3].var = self.baseColor[3] - ((ranged.life - self.life) / ranged.life) * self.baseColor[3]
end

local sin, cos = math.sin, math.cos
function ranged:shoot()
	local ang = self.angle + Base.toRadians(180)
	local speed = self.setspeed or 1.5 * v
	for i = 1, self.divideN do
		local e = self.shot.bodies:getFirstAvailable():revive()
		e.position:set(self.position)
		e.speed:set(sin(ang) * speed, cos(ang) * speed)
		e:register()
		ang = ang + self.angleDelta
	end
end

function ranged:kill()
	Body.kill(self)

	Effect.createEffects(self, 30)

	if self.causeOfDeath == "shot" then
		RecordsManager.addScore(25 * self.divideN)
		self.divideN = self.divideN + 3	
		self.angleDelta = Base.toRadians(360/self.divideN)
		self:shoot()
	end

	self.shootCircle.position = Vector:new{0, 0} -- restoring things
	self.shootCircle:kill()
	self.shootCircle = nil
	self.timeOutTimer:remove()
	self.shootTimer:remove()
end