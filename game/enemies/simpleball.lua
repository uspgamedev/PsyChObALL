simpleball = body:new {
	size = 20,
	__type = "simpleball"
}

simpleball.__init = enemy.__init

function simpleball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or (self.collides or self.x < -self.size or self.y < -self.size or self.x - self.size > width or self.y - self.size > height)
end

function simpleball:handleDelete()
	neweffects(self, 40)
end