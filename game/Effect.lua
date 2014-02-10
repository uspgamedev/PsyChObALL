
Effect = Body:new {
	size	 = 1.7,
	__type   = 'Effect',
	ord = 1,
	bodies = {}
}

Body.makeClass(Effect)

function Effect:start()
	Body.start(self)
	self.etc = 0
end

function Effect:update(dt)
	Body.update(self, dt)
	self.etc = self.etc + dt

	self.delete = self.delete or self.etc > self.timetogo
end

local ceil, random = math.ceil, math.random
function Effect.createEffects(based_on, times)
	times = ceil(times/2)
	--local speedinfluence = based_on.speed * .6
	if (based_on.alpha or (based_on.alphaFollows and based_on.alphaFollows.var) or 1) == 0 then return end
	local effs = Effect.bodies
	for i = 1, times do
		local e = Effect:new{
			position = based_on.position + {based_on.size * (2 * random() - 1), based_on.size * (2 * random() - 1)},
			variance = based_on.variance,
			coloreffect = based_on.coloreffect,
			alpha = based_on.alpha,
			alphaFollows = based_on.alphaFollows
		}

		e.speed:set(e.position):sub(based_on.position):normalize():mult(random() * v, random() * v)

		e.timetogo = random(300,1000) / 1000
		e:start()
		
		effs[#effs + 1] = e
	end
end

function Effect:handleDelete()
	Body.handleDelete(self)
end

function Effect:draw()
	local color = ColorManager.getComposedColor(self.variance, self.alphaFollows and self.alphaFollows.var or self.alpha, self.coloreffect)
	graphics.setColor(color)
	graphics.rectangle('fill', self.position[1], self.position[2], 2 * self.size, 2 * self.size)
end