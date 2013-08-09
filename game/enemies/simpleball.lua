simpleball = body:new {
	size = 20,
	coloreffect = getColorEffect(0, 0, 255, 40),
	__type = "simpleball"
}

simpleball.__init = enemy.__init

function simpleball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size)^2 >= (v.x - self.x)^2 + (v.y - self.y)^2 then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if psycho.canbehit and not gamelost and (psycho.size + self.size)^2 >= (psycho.x - self.x)^2 + (psycho.y - self.y)^2 then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function simpleball:handleDelete()
	neweffects(self, 40)
end