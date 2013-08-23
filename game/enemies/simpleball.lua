simpleball = body:new {
	size = 20,
	coloreffect = getColorEffect(0, 0, 255, 40),
	__type = "simpleball"
}

function simpleball:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
end

function simpleball:update( dt )
	body.update(self, dt)

	--if self.position[1] < -self.size or self.position[1] > width + self.size or self.position[2] < -self.size or self.position[2] > width + self.size then return end
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
	if self.diereason == 'shot' then addscore(25) end
	neweffects(self, 40)
end