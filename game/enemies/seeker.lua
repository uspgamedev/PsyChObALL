seeker = body:new {
	size = 20,
	__type = 'seeker'
}

function seeker:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
	self.speedN = self.speedN or math.random(v - 30, v)
end

function seeker:update( dt )
	self.speed:set(psycho.position):sub(self.position):normalize():mult(self.speedN, self.speedN)
	body.update(self, dt)

	for _, v in pairs(shot.bodies) do
		if not v.collides and self:collidesWith(v) then
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

function seeker:handleDelete()
	neweffects(self, 40)
end