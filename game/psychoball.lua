psychoball = body:new {
	size	 = 23,
	mode	 = 'fill',
	variance = 0
}

function psychoball:__init()
	self.ring = circleEffect:new {
		size = self.size,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 6,
		variance = colortimer.timelimit/2,
		index = 'psychoring'
	}
	self.ring.position = self.position

	function self.ring:draw()
		color(self.color, colortimer.time + self.variance, self.alpha)
		--[[self.color[1], self.color[2], self.color[3] = 
			self.color[1]/3, self.color[2]/3, self.color[3]/3
		self.color[1], self.color[2], self.color[3] = 
			255 - (255 - self.color[1])/1.3, 255 - (255 - self.color[2])/1.3, 255 - (255 - self.color[3])/1.3]]
		graphics.setColor(self.color)
		graphics.setLine(self.linewidth)
		graphics.circle('line', self.x, self.y, self.size)
		graphics.setLine(1)
	end
end

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
			psycho.ring.sizeGrowth = 0
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

	if self.ring.sizeGrowth < 0 and self.ring.size < self.size then
		self.ring.linewidth = 6
		self.ring.size = self.size
		self.ring.sizeGrowth = 0
	end

	for i,v in pairs(enemy.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			lostgame()
			self.diereason = "shot"
		end
	end
end

function psychoball:draw()
	if gamelost then return end
	body.draw(self)
	
end

function psychoball:handleDelete()
	self.speed:set(0,0)
	if self.ring then self.ring.sizeGrowth = -300 end
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
		self.ring.size = self.size - 2
		self.ring.sizeGrowth = 25
		self.ring.linewidth = 6
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
			self.ring.sizeGrowth = -300
			if not isPaused then do_ultrablast() end
		end
	end
end

function do_ultrablast()
	for i=1, ultrablast do
		shoot(psycho.x + (math.cos(math.pi * 2 * i / ultrablast) * 100), psycho.y + (math.sin(math.pi * 2 * i / ultrablast) * 100))
	end
end