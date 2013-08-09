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
		if not v.collides and (v.size + self.size)^2 >= (v.x - self.x)^2 + (v.y - self.y)^2 then
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

function seeker:handleDelete()
	neweffects(self, 40)
end