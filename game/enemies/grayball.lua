grayball = body:new {
	size = 20,
	coloreffect = noLSDeffect,
	__type = "grayball"
}

grayball.__init = enemy.__init

function grayball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size)^2 >= (v.x - self.x)^2 + (v.y - self.y)^2 then
			v.collides = true
			v.explosionEffects = true
		end
	end

	if psycho.canbehit and not gamelost and (psycho.size + self.size)^2 >= (psycho.x - self.x)^2 + (psycho.y - self.y)^2 then
		psycho.diereason = "shot"
		lostgame()
	end
end

function grayball:handleDelete()
	neweffects(self, 40)
end