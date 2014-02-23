Shot = Body:new {
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	shader = Base.circleShader,
	isUltraShot = false,
	shotnum = 1,
	bodies = Group:new{},
	__type   = 'Shot'
}

Body.makeClass(Shot)

function Shot.init()
	Shot.timer = Timer:new{
		timeLimit = .18,
		worksOnGameLost = false,
		persistent = true
	}

	function Shot.timer:callback() -- continues shooting when you hold the mouse
		Shot.bodies:reviveObjects(Shot.shotnum)
	end

	function Shot.timer:handleReset()
		self:stop()
	end
end

function Shot:revive()
	Body.revive(self)

	self.position:set(psycho.position)
	
	self.explosionEffects = Shot.explosionEffects
	self.size = Shot.size
	self.isUltraShot = Shot.isUltraShot

	if usingjoystick then
		self.speed:set(joystick.getAxis(1, 5), joystick.getAxis(1, 4)):normalize():mult(3*v, 3*v)
	else
		self.speed:set(mouse.getPosition()):sub(psycho.position):normalize():mult(3*v, 3*v)
	end

	return self
end

function Shot:kill()
	if not self.alive then return end
	Body.kill(self)
	if self.explosionEffects then Effect.createEffects(self, 7) end
end