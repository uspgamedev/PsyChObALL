grayball = body:new {
	size = 20,
	coloreffect = ColorManager.noLSDEffect,
	__type = "grayball"
}

function grayball:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
end

function grayball:update( dt )
	body.update(self, dt)

	if self.position[1] < self.size or self.position[1] > width + self.size or self.position[2] < self.size or self.position[2] > width + self.size then return end
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
	body.handleDelete(self)
	neweffects(self, 40)
end