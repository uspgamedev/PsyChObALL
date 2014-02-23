superball = Body:new {
	size = 40,
	life = 60,
	bouncesOnScreen = true,
	shader = Base.circleShader,
	ord = 6,
	__type = 'superball'
}

Body.makeClass(superball)

local random = math.random
function superball:revive(shot, exitpos, timeout)
	self.shot = shot and Enemies[shot] or state == survival and Enemy or Enemies.simpleball
	self.timeout = timeout
	self.exitposition = Base.clone(exitpos) or Base.clone(self.position)
	
	local vx, vy = random(v, v + 50), random(v, v + 50)
	vx = self.x < height/2 and vx or -vx
	vy = self.y < width/2 and vy or -vy
	self.speed:set(vx, vy)

	self.coloreffect = self.shot.coloreffect
	self.variance = self.shot.variance

	self.shotTimer = Timer:new {
		timeLimit = 1.5 + random(),
		worksOnGameLost = false,
		time = random() * 1.6
	}

	function self.shotTimer.callback( timer )
		timer.timeLimit = 1 + random()
		local e = self.shot.bodies:getFirstAvailable():revive()
		e.position:set(self.position)
		-- 15 degrees random 'error', should I keep this?
		e.speed:set(psycho.position):sub(self.position):normalize():mult(1.5 * v, 1.5 * v):rotate((random() - .5) * Base.toRadians(30))
		e:register()
	end

	if state == survival then 
		self.speedTimer = Timer:new {
			timeLimit = random() * 4 + 1
		}

		function self.speedTimer.callback(timer)
			timer.timeLimit = random() * 3 + 1
			local vx, vy = random(-50, 50), random(-50, 50)
			vx = vx + v * Base.sign(vx)
			vy = vy + v * Base.sign(vy)
			self.speed:set(vx, vy)
		end
	end

	self.life = superball.life
	self.bouncesOnScreen = superball.bouncesOnScreen

	self.timeoutTimer = nil

	return self
end

function superball:deactivate()
	Body.deactivate(self)
	self.shotTimer:stop()
	if self.timeoutTimer then self.timeoutTimer:stop() end
	if state == survival then self.speedTimer:stop() end
end

function superball:activate()
	Body.activate(self)
	self.shotTimer:start()
	if self.timeoutTimer then self.timeoutTimer:start() end
	if state == survival then self.speedTimer:start() end
end

function superball:start( shot )
	Body.start(self)

	self.originalHeath = self.life

	if self.timeout then
		self.timeoutTimer = Timer:new {
			timeLimit = self.timeout,
			onceOnly = true,
			callback = function()
				self.bouncesOnScreen = false
				self.speed:set(self.exitposition):sub(self.position):normalize():mult(1.1 * v, 1.1 * v)
				self.shotTimer:stop()
			end
		}

		self.timeoutTimer:start()
	end
end

function superball:draw()
	Body.draw(self)

	graphics.setColor(ColorManager.getComposedColor(self.variance, 60))
	graphics.setLineWidth(3)
	graphics.circle('line', self.position[1], self.position[2], self.life + self.size)
end

local abs = math.abs
function superball:update(dt)
	Body.update(self, dt)

	if self.bouncesOnScreen then
		if self.x  + self.size > width then self.speed:set(-abs(self.Vx))
		elseif self.x - self.size < 0  then self.speed:set( abs(self.Vx)) end

		if self.y + self.size > height then self.speed:set(nil, -abs(self.Vy))
		elseif self.y - self.size < 0  then self.speed:set(nil,  abs(self.Vy)) end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

	Shot.bodies:forEachAlive(function(shot)
		if self.alive and Base.collides(shot.position, shot.size, self.position, self.life + self.size) then
			self:manageShotCollision(shot)
		end
	end)
end

function superball:manageShotCollision( shot )
	shot.explosionEffects = false
	shot:kill()

	-- Creates explosion effects with the same color as the superball
	local bakvariance = shot.variance
	shot.variance = self.variance
	Effect.createEffects(shot,10)
	shot.variance = bakvariance

	self.life = self.life - 4

	if self.life <= 0 then
		self.causeOfDeath = 'shot'
		self:kill()
	end
end

function superball:kill()
	Body.kill(self)

	if self.causeOfDeath == 'shot' then RecordsManager.addScore(4 * self.originalHeath + 2 * self.size) end
	Effect.createEffects(self,100)

	self.shotTimer:remove()
	if self.timeoutTimer then self.timeoutTimer:remove() end

	if state == survival then self.speedTimer:remove() end
end