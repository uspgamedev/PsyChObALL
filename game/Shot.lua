Shot = Body:new {
	collides = false,
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	shader = base.circleShader,
	shotnum = 1,
	bodies = {},
	__type   = 'Shot'
}

Body.makeClass(Shot)

function Shot.init()
	Shot.timer = Timer:new{
		timelimit = .18,
		works_on_gameLost = false,
		persistent = true
	}

	function Shot.timer:funcToCall() -- continues shooting when you hold the mouse
		for i = 1, Shot.shotnum do
			if usingjoystick then
				Shot:new {
					position = psycho.position:clone(),
					speed	 = Vector:new{joystick.getAxis(1, 5), joystick.getAxis(1, 4)}:normalize():mult(3*v, 3*v)
					}:register()
			else
				Shot:new {
					position = psycho.position:clone(),
					speed	 = Vector:new {mouse.getPosition()}:sub(psycho.position):normalize():mult(3*v, 3*v)
					}:register()
			end
		end
	end

	function Shot.timer:handlereset()
		self:stop()
	end
end

function Shot:handleDelete()
	Body.handleDelete(self)
	if self.explosionEffects then neweffects(self, 7) end
	if not self.collides then neweffects(self, 7) end
end

function Shot:update(dt)
    Body.update(self, dt)
    self.delete = self.delete or self.collides
end