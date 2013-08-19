shot = body:new {
	collides = false,
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	__type   = 'shot',
	shotnum = 1,
	bodies = {}
}

function shot.init()
	shot.timer = timer:new{
		timelimit = .18,
		works_on_gamelost = false,
		persistent = true
	}

	function shot.timer:funcToCall() -- continues shooting when you hold the mouse
		for i = 1, shot.shotnum do
			if usingjoystick then
				shot:new {
					position = psycho.position:clone(),
					speed	 = vector:new{joystick.getAxis(1, 5), joystick.getAxis(1, 4)}:normalize():mult(3*v, 3*v)
					}:register()
			else
				shot:new {
					position = psycho.position:clone(),
					speed	 = vector:new {mouse.getPosition()}:sub(psycho.position):normalize():mult(3*v, 3*v)
					}:register()
			end
		end
	end

	function shot.timer:handlereset()
		self:stop()
	end
end

function shot:handleDelete()
	if self.explosionEffects then neweffects(self, 7) end
	if not self.collides then neweffects(self, 7) end
end

function shot:update(dt)
    body.update(self, dt)
    self.delete = self.delete or self.collides
end