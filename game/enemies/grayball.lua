grayball = Body:new {
	size = 20,
	coloreffect = ColorManager.noLSDEffect,
	shader = Base.circleShader,
	__type = "grayball"
}

Body.makeClass(grayball)

function grayball:revive()
	Body.revive(self)
	self.inScreen = false

	return self
end

function grayball:update( dt )
	Body.update(self, dt)
	if not self.inScreen then
		if self.position[1] < -self.size or self.position[1] > width + self.size or self.position[2] < -self.size or self.position[2] > width + self.size then return end
		self.inScreen = true
	end
	Shot.bodies:forEachAlive(function(shot)
		if self:collidesWith(shot) then
			shot.explosionEffects = true
			shot:kill()
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

function grayball:draw()
	if self.inScreen then Body.draw(self) end
end

function grayball:kill()
	Body.kill(self)
	Effect.createEffects(self, 40)
end