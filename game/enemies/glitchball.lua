glitchball = Body:new {
	size = 20,
	coloreffect = ColorManager.noLSDEffect,
	mode = 'line',
	lineWidth = 10,
	shader = Base.circleShader,
	__type = "glitchball"
}

Body.makeClass(glitchball)

glitchball.draw = CircleEffect.draw

function glitchball:update( dt )
	Body.update(self, dt)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

function glitchball:kill()
	Body.kill(self)
	Effect.createEffects(self, 40)
end