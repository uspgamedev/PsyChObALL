psychoball = circleEffect:new {
	size	 = 23,
	mode	 = 'fill',
	variance = 0,
	sizeGrowth = 0,
	alpha = 255,
	index = false,
	changesimage = true,
	__index = circleEffect.__index,
	__newindex = circleEffect.__newindex
}

function psychoball.init()
	ultrablastmax = 84 -- maximum number of shots on ultrablast
	ultratimer = timer:new {
		timelimit  = .02,
		persistent = true
	}

	function ultratimer:funcToCall() -- adds more shots to ultrablast
		if ultrablast < ultrablastmax then
			ultrablast = ultrablast + 1
		end
		if ultrablast == ultrablastmax - 1 then
			psycho.sizeGrowth = 0
		end
	end

	function ultratimer:handlereset()
		self:stop()
	end
end

function psychoball:update(dt)
	if gamelost then return end
	self.position:add(self.speed * dt)

	self.position:set(
		math.max(self.size, math.min(width - self.size, self.position[1])),
		math.max(self.size, math.min(height - self.size, self.position[2]))
	)

	if self.sizeGrowth < 0 and self.size < 23 then
		self.linewidth = 6
		self.size = 23
		self.sizeGrowth = 0
	end

	for i,v in pairs(enemy.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			lostgame()
			self.diereason = "shot"
		end
	end

	circleEffect.update(self, dt)
end

function psychoball:draw()
	if gamelost then return end
	body.draw(self)
end

function psychoball:handleDelete()
	self.speed:set(0,0)
	if self then self.sizeGrowth = -300 end
	neweffects(self,80)
end

function psychoball:keypressed( key )
	auxspeed:add(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v*1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v*1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v*1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v*1.3 or 0)
	)
	self.speed:set(auxspeed)

	if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if key == ' ' and not isPaused and onGame() and ultracounter > 0 then
		ultracounter = ultracounter - 1
		ultrablast = 10
		self.sizeGrowth = 17
		self.linewidth = 6
		ultratimer:start()
	end
end

function psychoball:keyreleased( key )
	auxspeed:sub(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v * 1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v * 1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v * 1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v * 1.3 or 0)
	)
	self.speed:set(auxspeed)

	if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if key == ' ' then
		if ultratimer.running then
			ultratimer:stop()
			self.sizeGrowth = -300
			if not isPaused then do_ultrablast() end
		end
	end
end

function do_ultrablast()
	for i=1, ultrablast do
		shoot(psycho.x + (math.cos(math.pi * 2 * i / ultrablast) * 100), psycho.y + (math.sin(math.pi * 2 * i / ultrablast) * 100))
	end
end