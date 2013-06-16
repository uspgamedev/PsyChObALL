shot = body:new {
	collides = false,
	size 	 = 4,
	variance = 0,
	explosionEffects = true,
	__type   = 'shot',
	bodies = {}
}

function shot.init()
	shot.timer = timer:new{
		timelimit = .18,
		persistent = true
	}

	function shot.timer:funcToCall() -- continues shooting when you hold the mouse
		shoot(mouse.getPosition()) 
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
    self.position:add(self.speed * dt)
    self.delete = self.delete or (self.collides or self.x < -self.size or self.y < -self.size or self.x + self.size > width or self.y + self.size > height)
end