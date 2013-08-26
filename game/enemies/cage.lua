cage = CircleEffect:new {
	size = width,
	speedN = v*.4,
	maxsize = width*2,
	onLocation = true,
	lastexecuted = 0,
	alpha = 255,
	sizeGrowth = 40,
	linewidth = 8,
	index = false,
	__type = 'cage'
}

Body.makeClass(cage)

function cage:update( dt )
	CircleEffect.update(self, dt)
	Body.update(self, dt)

	if self.desiredsize and ((self.sizeGrowth > 0 and self.size > self.desiredsize) 
		or (self.sizeGrowth < 0 and self.size < self.desiredsize)) then
		self.size = self.desiredsize
		self.sizeGrowth = 0
		self.desiredsize = nil
		if self.destroy then self.delete = true end
	end

	if not self.onLocation then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1 or curdist > self.prevdist then
			self.position:set(self.target)
			self.speed:reset()
			self.target = nil
			self.onLocation = true
			self.prevdist = nil
		else
			self.prevdist = curdist
		end
	end
	
	if (self.size - psycho.size - psycho.sizediff - self.linewidth + 3)^2 < self.position:distsqr(psycho.position) then
		psycho.position:sub(self.position):normalize():mult(self.size - psycho.size - psycho.sizediff - self.linewidth + 3):add(self.position)
	end
end

function cage:doaction( actN )
	local act = self.actions[actN]
	while act do
		self.lastexecuted = actN
		if act.size then
			self.desiredsize = act.size
			self.sizeGrowth = math.abs(act.sizeGrowth or cage.sizeGrowth) * base.sign(act.size - self.size)
		end
		if act.speed then
			self.speedN = act.speed
		end
		if act.moveto then
			self.onLocation = false
			self.target = base.clone(act.moveto)
			self.prevdist = self.position:distsqr(self.target)
			self.speed:set(self.target):sub(self.position):normalize():mult(self.speedN, self.speedN)
		end
		if act.destroy then
			self.desiredsize = width
			self.sizeGrowth = act.sizeGrowth or cage.sizeGrowth
			self.destroy = true
		end
		if act.wait then
			Timer:new{
				timelimit = act.wait,
				running = true,
				onceonly = true,
				funcToCall = function() self:doaction(actN + 1) end
			}
			act = nil
		else
			actN = actN + 1
			act = self.actions[actN]
		end
	end
end

function cage:onInit( pos1, ...)
	self.variance = math.random()*6 + 2
	self.position = Vector:new(base.clone(pos1))
	self.actions = {...}
end

function cage:start()
	self:doaction(1)
end

cage.getWarning = base.doNothing
cage.freeWarning = base.doNothing