ultrashot = Body:new {
	collides = false,
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	__type   = 'ultrashot',
	shader = base.circleShader,
	ultrashotnum = 1,
	bodies = {}
}

Body.makeClass(ultrashot)

function ultrashot:handleDelete()
	Body.handleDelete(self)
	if self.explosionEffects then neweffects(self, 7) end
	if not self.collides then neweffects(self, 7) end
end

function ultrashot:update(dt)
	Body.update(self, dt)
	self.delete = self.delete or self.collides
end