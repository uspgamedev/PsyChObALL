grayball = Body:new {
	size = 20,
	coloreffect = ColorManager.noLSDEffect,
	shader = base.circleShader,
	spriteBatch = graphics.newSpriteBatch(base.pixel, 300, 'dynamic'),
	spriteMaxNum = 300,
	spriteSafety = 10,
	__type = "grayball"
}

Body.makeClass(grayball)

function grayball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
end

function grayball:update( dt )
	Body.update(self, dt)

	if self.position[1] < self.size or self.position[1] > width + self.size or self.position[2] < self.size or self.position[2] > width + self.size then return end
	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			v.collides = true
			v.explosionEffects = true
		end
	end

	if psycho.canbehit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
end

function grayball:handleDelete()
	Body.handleDelete(self)
	neweffects(self, 40)
end