grayball = body:new {
	size = 20,
	coloreffect = noLSDeffect,
	__type = "grayball"
}

function grayball:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
end

function grayball:update( dt )
	body.update(self, dt)

	for _, v in pairs(shot.bodies) do
		if self:collidesWith(v) then
			v.collides = true
			v.explosionEffects = true
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function grayball:handleDelete()
	neweffects(self, 40)
end