grayball = body:new {
	size = 20,
	coloreffect = noLSDeffect,
	__type = "grayball"
}

grayball.__init = enemy.__init

function grayball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			v.collides = true
			v.explosionEffects = true
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function grayball:handleDelete()
	neweffects(self, 40)
end