glitchball = Body:new {
	size = 20,
	coloreffect = ColorManager.noLSDEffect,
	mode = 'line',
	linewidth = 10,
	spriteBatch = false,
	__type = "glitchball"
}

Body.makeClass(glitchball)

function glitchball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
end

glitchball.draw = CircleEffect.draw

function glitchball:update( dt )
	Body.update(self, dt)

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function glitchball:handleDelete()
	neweffects(self, 40)
end