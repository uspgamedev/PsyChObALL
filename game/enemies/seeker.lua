seeker = body:new {
	size = 20,
	__type = 'seeker'
}

function seeker:__init()
	enemy.__init(self)
	self.speedN = math.random(v - 30, v)
end

function seeker:update( dt )
	self.speed:set(psycho.position):sub(self.position):normalize():mult(self.speedN, self.speedN)
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if not v.collides and (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
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

function seeker:handleDelete()
	neweffects(self, 40)
end