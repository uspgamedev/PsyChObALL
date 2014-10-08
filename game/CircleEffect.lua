CircleEffect = Body:new {
	alpha = 10,
	maxSize = width / 1.9,
	mode = 'line',
	__type = 'CircleEffect',
	lineWidth = 4,
	shader = Base.circleShader,
	ord = 3,
	bodies = Group:new{}
}

Body.makeClass(CircleEffect)

function CircleEffect:revive( based_on )
	Body.revive(self)

	if based_on then
		self.position:set(based_on.position)
		self.size = based_on.size
		self.variance = based_on.variance
	end

	self.alpha = CircleEffect.alpha
	self.maxSize = CircleEffect.maxSize
	self.mode = CircleEffect.mode
	self.lineWidth = CircleEffect.lineWidth
	self.growToSize = CircleEffect.growToSize -- nil
	
	self.sizeGrowth = math.random(120, 160)
	self.variance = math.random() * ColorManager.colorCycleTime

	return self
end

function CircleEffect.init()
	CircleEffect.timer = Timer:new{
		timeLimit = .2,
		running = true,
		persistent = true
	}

	function CircleEffect.timer:callback() -- releases cirleEffects
		if onGame() and not DeathManager.gameLost then
			CircleEffect.bodies:getFirstDead():revive(psycho)
		end
		if state == survival then
			Enemy.bodies:forEachAlive(function(enemy)
				if enemy.size >= 15 and math.random() < .5 --[[reducing chance]] then
					CircleEffect.bodies:getFirstDead():revive(enemy)
				end
			end)
		end
	end
end

function CircleEffect:draw()
	graphics.setLineWidth(self.lineWidth)
	Base.defaultDraw(self)
end

function CircleEffect:update(dt)
	self.size = self.size + self.sizeGrowth * dt
	if self.growToSize then
		if self.sizeGrowth > 0 then
			if self.size >= self.growToSize then
				self.size = self.growToSize
				self.sizeGrowth = 0
				self.growToSize = nil
			end
		else
			if self.size <= self.growToSize then
				self.size = self.growToSize
				self.sizeGrowth = 0
				self.growToSize = nil
			end
		end
	end

	if (self.size < 0 or self.size > self.maxSize) then self:kill() end
end