local sizediff = 9
psychoball = circleEffect:new {
	size	 = 23 - sizediff,
	maxsize = width,
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
	body.update(self, dt)

	self.position:set(
		math.max(self.size + sizediff, math.min(width - self.size - sizediff, self.position[1])),
		math.max(self.size + sizediff, math.min(height - self.size - sizediff, self.position[2]))
	)

	if self.sizeGrowth < 0 and self.size + sizediff < 23 then
		self.linewidth = 6
		self.size = 23 - sizediff
		self.sizeGrowth = 0
	end

	circleEffect.update(self, dt)
end

function psychoball:draw()
	if gamelost then return end
	self.size = self.size + sizediff
	body.draw(self)
	self.size = self.size - sizediff
end

local effects = {
	function ( p1, p2, size )
		return size
	end,
	function ( p1, p2, size )
		return 1/math.random()
	end,
	function ( p1, p2, size )
		return p1:dist(p2)
	end,
	function ( p1, p2, size )
		return p1:distsqr(p2)/size
	end,
	function ( p1, p2, size )
		return (size - p1:dist(p2))
	end,
	function ( p1, p2, size )
		return (size^2 - p1:distsqr(p2))/size
	end,
	function ( p1, p2, size )
		return (size - p1:distsqr(p2))/size
	end,
	function ( p1, p2, size )
		return math.random()*size
	end,
	function ( p1, p2, size )
		return size/(math.random() + .3)
	end,
	function ( p1, p2, size )
		return (size^1.6)/p1:dist(p2)
	end,
	function ( p1, p2, size )
		return math.tan(p1:distsqr(p2))
	end,
	function ( p1, p2, size )
		return math.asin(p1:dist(p2) % 1)*size^.8
	end,
	function ( p1, p2, size )
		return math.exp(p1:dist(p2) - size/1.3)
	end,
	function ( p1, p2, size )
		return math.log10(p1:dist(p2))*size^.7
	end
}

function psychoball:handleDelete()
	lives = lives - 1
	self.size = self.size + sizediff
	self.speed:set(0,0)
	local deatheffects = {}
	self.sizeGrowth = -300
	local efunc = effects[math.random(#effects)]
	for i = self.x - self.size, self.x + self.size, effect.size/1.5 do
		for j = self.y - self.size, self.y + self.size, effect.size/1.5 do
			if (i - self.x)^2 + (j - self.y)^2 <= self.size^2 then
				local e = effect:new{
					position = vector:new{i, j},
					variance = self.variance,
					coloreffect = self.coloreffect,
					alpha = self.alpha,
					alphafollows = self.alphafollows
				}
				local distr = efunc(e.position, self.position, self.size)
				e.speed = (e.position - self.position):normalize():mult(v * distr, v * distr)

				e.timetogo = math.huge
				e.etc = 0
				
				table.insert(deatheffects, e)
			end
		end
	end
	deatheffects[1].firstpos = deatheffects[1].position:clone()
	deatheffects[1].update = function ( self, dt )
		effect.update(self, dt)
		if gamelostinfo.isrestarting and not self.speed:equals(0, 0) then
			local curdist = self.position:distsqr(self.firstpos)
			if curdist == 0 or curdist > self.prevdist then
				if state == story then reloadStory()
				elseif state == survival then reloadSurvival() end
				paintables.psychoeffects = nil
				return
			end
			self.prevdist = curdist
		end
	end
	self.size = self.size - sizediff
	paintables.psychoeffects = deatheffects	
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