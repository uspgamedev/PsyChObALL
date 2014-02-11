simpleball = Body:new {
	size = 20,
	coloreffect = ColorManager.getColorEffect(0, 0, 255, 40),
	shader = Base.circleShader,
	score = 25,
	__type = "simpleball"
}

Body.makeClass(simpleball)

function simpleball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
end

function simpleball:update( dt )
	Body.update(self, dt)

	if self.position[1] < -self.size or self.position[1] > width + self.size or self.position[2] < -self.size or self.position[2] > width + self.size then return end
	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			self:manageShotCollision(v)
			break
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

	self.delete = self.delete or self.collides
end

function simpleball:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	self.collides = true
	self.causeOfDeath = shot.isUltraShot and 'ultrashot' or 'shot'
end

function simpleball:handleDelete()
	Body.handleDelete(self)
	Effect.createEffects(self, 40)
end