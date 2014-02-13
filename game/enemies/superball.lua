superball = Body:new {
	size = 40,
	variance = 13,
	life = 60,
	timeout = 40,
	collides = true,
	shader = Base.circleShader,
	ord = 6,
	__type = 'superball'
}

Body.makeClass(superball)

local random = math.random
function superball:revive()
	local vx, vy = random(v, v + 50), random(v, v + 50)
	vx = self.x < height/2 and vx or -vx
	vy = self.y < width/2 and vy or -vy
	self.speed	  = Vector:new {vx, vy}

	self.coloreffect = self.shot.coloreffect
	self.variance = self.shot.variance

	self.shoottimer = Timer:new {
		timelimit = 1.5 + random(),
		works_on_gameLost = false,
		time = random() * 1.6
	}

	function self.shoottimer.funcToCall( timer )
		timer.timelimit = 1 + random()
		local e = self.shot.bodies:getFirstAvailable():revive()
		e.position:set(self.position)
		-- 15 degrees random 'error', should I keep this?
		e.speed:set(psycho.position):sub(self.position):normalize():mult(1.5 * v, 1.5 * v):rotate((random() - .5) * Base.toRadians(30))
		e:register()
	end

	if state == survival then 
		self.speedtimer = Timer:new {
			timelimit = random() * 4 + 1
		}

		function self.speedtimer.funcToCall(timer)
			timer.timelimit = random() * 3 + 1
			local vx, vy = random(-50, 50), random(-50, 50)
			vx = vx + v * Base.sign(vx)
			vy = vy + v * Base.sign(vy)
			self.speed:set(vx, vy)
		end
	end

	self.lifeCircle = CircleEffect.bodies:getFirstAvailable():revive() 
	self.lifeCircle.alpha = 60
	self.lifeCircle.sizeGrowth = 0
	self.lifeCircle.linewidth = 6
	self.lifeCircle.position = self.position -- yes, no cloning, just the SAME SAME position
	self.lifeCircle.size = self.size + self.life

	self.timeoutTimer = nil

	return self
end

function superball:deactivate()
	Body.deactivate(self)
	self.lifeCircle:deactivate()
	self.shoottimer:stop()
	if self.timeoutTimer then self.timeoutTimer:stop() end
	if state == survival then self.speedtimer:stop() end
end

function superball:activate()
	Body.activate(self)
	self.lifeCircle:activate()
	self.shoottimer:start()
	if self.timeoutTimer then self.timeoutTimer:start() end
	if state == survival then self.speedtimer:start() end
end

function superball:onInit( shot, exitpos, timeout, ... )
	self.shot = shot and Enemies[shot] or state == survival and Enemy or Enemies.simpleball
	self.timeout = timeout
	self.exitposition = self.exitposition or Base.clone(exitpos) or Base.clone(self.position)
end

function superball:start( shot )
	Body.start(self)

	self.originalHeath = self.life
	self.lifeCircle.size = self.size + self.life

	if self.timeout then
		self.timeoutTimer = Timer:new {
			timelimit = self.timeout,
			onceOnly = true,
			funcToCall = function()
				self.collides = false
				self.speed:set(self.exitposition):sub(self.position):normalize():mult(1.1 * v, 1.1 * v)
				self.shoottimer:stop()
			end
		}

		self.timeoutTimer:start()
	end
end

local abs = math.abs
function superball:update(dt)
	Body.update(self, dt)

	if self.collides then
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
		if self.alive and Base.collides(shot, self.lifeCircle) then
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
	self.lifeCircle.size = self.size + self.life

	if self.life <= 0 then
		self.causeOfDeath = 'shot'
		self:kill()
	end
end

function superball:kill()
	Body.kill(self)

	if self.causeOfDeath == 'shot' then RecordsManager.addScore(4 * self.originalHeath + 2 * self.size) end
	Effect.createEffects(self,100)
	self.lifeCircle.sizeGrowth = -300

	self.shoottimer:remove()
	if self.timeoutTimer then self.timeoutTimer:remove() end

	if state == survival then self.speedtimer:remove() end
end