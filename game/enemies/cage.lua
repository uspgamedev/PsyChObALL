cage = CircleEffect:new {
	size = width,
	speedN = v * .4,
	maxSize = width * 2,
	onLocation = true,
	alpha = 255,
	sizeGrowth = 40,
	lineWidth = 8,
	__type = 'cage'
}

Body.makeClass(cage)

function cage:update( dt )
	Body.update(self, dt)
	self.size = self.size + self.sizeGrowth * dt

	if self.growToSize and ((self.sizeGrowth > 0 and self.size > self.growToSize) 
		or (self.sizeGrowth < 0 and self.size < self.growToSize)) then
		self.size = self.growToSize
		self.sizeGrowth = 0
		self.growToSize = nil
		if self.destroy then self:kill() end
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
	
	if (self.size - psycho.size - psycho.sizeDiff - self.lineWidth + 3)^2 < self.position:distsqr(psycho.position) then
		psycho.position:sub(self.position):normalize():mult(self.size - psycho.size - psycho.sizeDiff - self.lineWidth + 3):add(self.position)
	end
end

local abs = math.abs
function cage:doAction( actN )
	local act = self.actions[actN]
	while act do
		if act.size then
			self.growToSize = act.size
			self.sizeGrowth = abs(act.sizeGrowth or cage.sizeGrowth) * Base.sign(act.size - self.size)
		end

		if act.speed then
			self.speedN = act.speed
		end

		if act.moveto then
			self.onLocation = false
			self.target = Base.clone(act.moveto)
			self.prevdist = self.position:distsqr(self.target)
			self.speed:set(self.target):sub(self.position):normalize():mult(self.speedN, self.speedN)
		end

		if act.destroy then
			self.growToSize = width
			self.sizeGrowth = act.sizeGrowth or cage.sizeGrowth
			self.destroy = true
		end

		if act.wait then
			self.waitTimer = self.waitTimer or Timer:new{
				timeLimit = act.wait,
				onceOnly = true
			}
			self.waitTimer.callback = function() self:doAction(actN + 1) end
			self.waitTimer:register()
			self.waitTimer:start(0)
			act = nil
		else
			actN = actN + 1
			act = self.actions[actN]
		end
	end
end

function cage:revive( pos1, ... )
	Body.revive(self)

	self.variance = math.random() * 6 + 2
	self.position:set(pos1)
	self.actions = {...}

	return self
end

function cage:start()
	Body.start(self)

	self:doAction(1)
end

cage.getWarning = Base.doNothing
cage.freeWarning = Base.doNothing