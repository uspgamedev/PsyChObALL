simpleball = body:new {
	size = 20,
	coloreffect = getColorEffect(0, 0, 255, 40),
	__type = "simpleball"
}

simpleball.__init = enemy.__init

function simpleball:update( dt )
	body.update(self, dt)

	for _, v in pairs(shot.bodies) do
		if self:collidesWith(v) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function simpleball:handleDelete()
	neweffects(self, 40)
end