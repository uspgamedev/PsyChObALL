
Effect = Body:new {
	size	 = 1.7,
	__type   = 'Effect',
	ord = 1,
	bodies = Group:new{}
}

Body.makeClass(Effect)

function Effect:update(dt)
	Body.update(self, dt)
	if not self.alive then return end
	self.time = self.time + dt

	if self.time > self.expireTime then
		self:kill()
	end
end

local ceil, random = math.ceil, math.random
function Effect:revive( based_on )
	Body.revive(self)

	self.position:set(based_on.position):add(based_on.size * (2 * random() - 1), based_on.size * (2 * random() - 1))
	self.variance = based_on.variance
	self.coloreffect = based_on.coloreffect
	self.alpha = based_on.alpha
	self.alphaFollows = based_on.alphaFollows

	self.size = Effect.size

	self.speed:set(self.position):sub(based_on.position):normalize():mult(random() * v, random() * v)

	self.expireTime = .3 + random() * .7
	self.time = 0

	return self
end

function Effect.createEffects( based_on, times )
	times = ceil(times/2)
	if (based_on.alpha or (based_on.alphaFollows and based_on.alphaFollows.var) or 1) == 0 then return end

	Effect.bodies:reviveObjects(times, based_on)
end

function Effect:draw()
	local color = ColorManager.getComposedColor(self.variance, self.alphaFollows and self.alphaFollows.var or self.alpha, self.coloreffect)
	graphics.setColor(color)
	graphics.rectangle('fill', self.position[1], self.position[2], 2 * self.size, 2 * self.size)
end