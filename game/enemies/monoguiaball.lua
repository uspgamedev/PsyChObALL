monoguiaball = Body:new {
	size =  25,
	divideN = 3,
	coloreffect = ColorManager.getColorEffect(20, 140, 0),
	score = 100,
	shader = Base.circleShader,
	__type = 'monoguiaball'
}

Body.makeClass(monoguiaball)

function monoguiaball:revive()
	Enemies.multiball.revive(self)
	self.divideType = Enemies.multiball

	return self
end

function monoguiaball:update( dt )
	Enemies.simpleball.update(self, dt)
end

function monoguiaball:manageShotCollision( shot )
	Enemies.simpleball.manageShotCollision(self, shot)
end

function monoguiaball:kill()
	Enemies.multiball.kill(self)
end