simpleball = Body:new {
	size = 20,
	coloreffect = ColorManager.getColorEffect(0, 0, 255, 40),
	shader = Base.circleShader,
	score = 25,
	__type = 'simpleball'
}

Body.makeClass(simpleball)

function simpleball:revive()
	Body.revive(self)

	self.size = simpleball.size
	self.score = simpleball.score

	return self
end

function simpleball:update( dt )
	Body.update(self, dt)

	if self.position[1] < -self.size or self.position[1] > width + self.size or self.position[2] < -self.size or self.position[2] > width + self.size then return end
	
	Shot.bodies:forEachAlive(function(shot)
		if self.alive and self:collidesWith(shot) then
			self:manageShotCollision(shot)
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

function simpleball:manageShotCollision( shot )
	shot.explosionEffects = false
	shot:kill()

	self.causeOfDeath = shot.isUltraShot and 'ultrashot' or 'shot'
	self:kill()
end

function simpleball:kill()
	Body.kill(self)

	Effect.createEffects(self, 40)
end