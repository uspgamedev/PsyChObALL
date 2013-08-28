ultrashot = body:new {
	collides = false,
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	__type   = 'ultrashot',
	ultrashotnum = 1,
	bodies = {}
}

function ultrashot.init()
	ultrashot.timer = timer:new{
		timelimit = .18,
		works_on_gamelost = false,
		persistent = true
	}

	function ultrashot.timer:funcToCall() -- continues shooting when you hold the mouse
		for i = 1, ultrashot.ultrashotnum do
			if usingjoystick then
				ultrashot:new {
					position = psycho.position:clone(),
					speed	 = vector:new{joystick.getAxis(1, 5), joystick.getAxis(1, 4)}:normalize():mult(3*v, 3*v)
					}:register()
			else
				ultrashot:new {
					position = psycho.position:clone(),
					speed	 = vector:new {mouse.getPosition()}:sub(psycho.position):normalize():mult(3*v, 3*v)
					}:register()
			end
		end
	end

	function ultrashot.timer:handlereset()
		self:stop()
	end
end

function ultrashot:handleDelete()
	if self.explosionEffects then neweffects(self, 7) end
	if not self.collides then neweffects(self, 7) end
end

function ultrashot:update(dt)
    body.update(self, dt)
    self.delete = self.delete or self.collides
end